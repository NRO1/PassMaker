const express = require("express");
const cors = require("cors");
require("dotenv").config();
const app = express();
const bodyParser = require("body-parser");
const makerRoutes = require("./routes/maker-routes")

app.use(cors());
app.use(bodyParser.json())

app.get('/:len', makerRoutes)
app.get('/:len/*', makerRoutes)

app.get("/", function (req, res) {
  res.send("appMaker_be");
});

app.listen(process.env.PORT, () => {
  console.log(`running on port ${process.env.PORT}`);
});
