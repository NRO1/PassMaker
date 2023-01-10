import React, { useRef, useState } from "react";
import classes from "./Config.module.css";
import axios from "axios";

const Config = () => {
  const [sym, setSym] = useState(false);
  const [dup, setDup] = useState(false);
  const [gotRes, setGotRes] = useState(false);
  const [pass, setPass] = useState("");
  const length = useRef();

  //form submit handler
  const submit = async (event) => {
    event.preventDefault();
    setPass("");

    let form = {};
    if (length.current.value > 20 || length.current.value < 6) {
      alert("Password must be 6 - 20 charcters long");
    } else {
      form.len = length.current.value;
    }
    form.symbols = sym;
    form.duplicates = dup;

    // Define the url params to send to the backend
    let urlParam = "";

    if (!form.symbols && !form.duplicates) {
      urlParam = form.len;
    } else if (form.symbols && !form.duplicates) {
      urlParam = `${form.len}/full`;
    } else if (form.symbols && form.duplicates) {
      urlParam = `${form.len}/fullnd`;
    }

    // Fetch the password from the backend
    let passArray = [];

    await axios
      .get(`http://localhost:8000/${urlParam}`)
      .then(function (response) {
        for (const el of response.data.password) {
          passArray.push(el);
        }
      });

    let flatPass = passArray.join("");
    setGotRes(true);
    setPass(flatPass);
  };

  //Symbols input handler
  const getSym = (e) => {
    setSym(e.target.checked);
  };

  //Duplicate input handler
  const getDup = (e) => {
    setDup(e.target.checked);
  };

  return (
    <div>
      <div className={classes.config}>
        <h2 className={classes.configHeader}>configuration</h2>
      </div>
      <form className={classes.configStruct}>
        <div className={classes.configAlign}>
          <label htmlFor="length-input">Length (6 - 20 characters)</label>
          <input type="number" id="length-input" ref={length} className={classes.inputWidth} />
        </div>
        <div className={classes.configAlign}>
          <label htmlFor="symbols">Allow symbols (!@#$%^&*+) ?</label>
          <input type="checkbox" id="symbols" onChange={getSym} />
        </div>
        <div className={classes.configAlign}>
          <label htmlFor="dup">Exclude duplicates ?</label>
          <input type="checkbox" id="dup" onChange={getDup} />
        </div>
        <div className={classes.configAlign}>
          <button onClick={submit}>Generate</button>
        </div>
      </form>
      {gotRes && (
        <div className={classes.passContainer}>
          <p>Password:</p>
          <p>{pass}</p>
        </div>
      )}
    </div>
  );
};

export default Config;
