const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const { it } = require('node:test');
const app = express();

dotenv.config();
const PORT = process.env.PORT;
app.use(express.json());

let itemsList = [
    {id:1,name:"name here"}
];




//api routes
app.get('/api/items',(req,res)=>{
    return res.json(itemsList);
});
app.post('/api/items', (req, res) => {
    let newTask = {
        id: itemsList.length + 1,
        name: req.body.name
    };
    itemsList.push(newTask);
    res.status(201).json(newTask);
});
app.put('/api/items/:id', (req, res) => {
    let itemId = parseInt(req.params.id); 
    let updatedName = req.body.name;
    let index = itemsList.findIndex(item => item.id === itemId);

    if (index !== -1) {
        itemsList[index].name = updatedName; // Update only the name property
        res.json(itemsList[index]); 
    } else {
        res.status(404).json({ msg: "Item not found" });
    }
});

app.delete('/api/items/:id', (req, res) => {
    let itemId = parseInt(req.params.id, 10); // Parse id to integer
    let index = itemsList.findIndex(item => item.id === itemId);
    if (index !== -1) {
      let deletedItem = itemsList.splice(index, 1)[0];
      res.json({ message: "Item deleted successfully", deletedItem });
    } else {
      res.status(404).json({ message: "Item not found" });
    }
  });



app.listen(PORT,(req,res)=>{
    console.log(`server is starte port : ${PORT}`);
})