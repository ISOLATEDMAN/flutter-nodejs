import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uiss/item.dart';
import 'package:http/http.dart' as http;
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final String serverUrl = "http://localhost:3000";

  Future<List<Item>> fetchItems()async{
      final response = await http.get(Uri.parse('$serverUrl/api/items'));
      if(response.statusCode == 200){
        final List<dynamic> itemList = jsonDecode(response.body);
        final List<Item> items = itemList.map((item){
          return Item.fromJson(item);
        }).toList();
        return items;
      }else{
        throw Exception("failed to fetch the data");
      }
  }
  
Future<Item> postItem(String name) async {
  final client = http.Client();
  try {
    final response = await client.post(
      Uri.parse('$serverUrl/api/items'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name}),
    );
    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final item = Item.fromJson(json);
      return item;
    } else {
      throw HttpException(
        'Failed to create item. Status code: ${response.statusCode}, Body: ${response.body}',
      );
    }
  } catch (e) {
    rethrow;
  } finally {
    client.close();
  }
}

Future<Item?> updateItem(int id, String name) async {
  final response = await http.put(
    Uri.parse('$serverUrl/api/items/$id'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'name': name}),
  );

  if (response.statusCode == 200) { // Check for 200 instead of 201
    final json = jsonDecode(response.body);
    return Item.fromJson(json); // Return the updated item
  } else {
    throw Exception("Can't update item. Status code: ${response.statusCode}");
  }
}


Future<void> deleteItem(int id, VoidCallback onDeleteSuccess) async {
  final response = await http.delete(
    Uri.parse('$serverUrl/api/items/$id'),
  );

  if (response.statusCode == 200 || response.statusCode == 204) {
    onDeleteSuccess(); // Call the callback function after successful deletion
  } else {
    throw Exception("Can't delete item. Status code: ${response.statusCode}");
  }
}



  TextEditingController _cont = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 172, 6),
      body: Column(
        
        children: [
          SizedBox(height: 60,),
          FutureBuilder(future: fetchItems(), builder: (context,snapshot){
              if(snapshot.hasData){
                return ListView.builder(
                  
                  shrinkWrap: true,
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context,index){
                    final item = snapshot.data![index];
                    return ListTile(
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(onPressed: (){
                            deleteItem(item.id,() {
                              setState(() {
                                
                              });
                            },);
                          }, icon: Icon(Icons.delete)),
                          IconButton(onPressed: (){
                            showDialog(context: context,
                                   builder: (context){
                                    return AlertDialog(
                                      title: Text('edit item..'),
                                      content: TextFormField(
                                        controller: _cont,
                                        decoration: InputDecoration(
                                          labelText: 'Enter name dude'
                                        ),
                                      ),
                                      actions: [
                                        TextButton(onPressed: (){
                                          Navigator.pop(context);
                                        }, child: Text('cancel')),
                                        TextButton(onPressed: (){
                                          updateItem(item.id,_cont.text);
                                          setState(() {
                                             _cont.clear();
                                          });
                                         Navigator.pop(context);
                                        }, child: Text('edit')),
                                      ],
                                    );
                                    
                                   });
                          },icon:Icon(Icons.edit)),
                        ],
                      ),
                      textColor: Colors.white,
                      title: Text(item.name,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
                    );
                });
              }
              else if(snapshot.hasError){
                return Center(child: Text("${snapshot.error.toString()}"),);
              }
              else{
                return Center(child: CircularProgressIndicator(),);
              }
          })
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        showDialog(context: context,
         builder: (context){
          return AlertDialog(
            title: Text('add item..'),
            content: TextFormField(
              controller: _cont,
              decoration: InputDecoration(
                labelText: 'Enter name dude'
              ),
            ),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text('cancel')),
              TextButton(onPressed: (){
                postItem(_cont.text);
                setState(() {
                   _cont.clear();
                });
               Navigator.pop(context);
              }, child: Text('add')),
            ],
          );
          
         });
      },
      child: Icon(Icons.add),),
    );
    
  }
}