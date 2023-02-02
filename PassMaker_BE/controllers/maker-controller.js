const AWS = require('aws-sdk')
const nums = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
const syms = ["!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "{", "}", "[", "]", ":", "?"]
const uc = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "o", "P", "Q", "R", "S", "T", "U", "V",
          "W", "X", "Y", "Z"]
const lc = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
          "w", "x", "y", "z"]

// AWS configuration and functions
AWS.config.update({region: 'eu-central-1'});
const sqs = new AWS.SQS({apiVersion: '2012-11-05'});


// Create a password with numbers, Uppercase and Lowercase letters based on the length from the frontend
const createNoSymPass = (req,res,next) => {
const len = req.params.len
let pass = []

for (i = 1; i <= len; i++ ) {
    let randChoice = Math.floor(Math.random() * 4)
        if (randChoice === 0) {
            let randNum = Math.floor(Math.random() * nums.length)
            pass.push(nums[randNum])
        } else if (randChoice === 2) {
            let randLc = Math.floor(Math.random() * lc.length)
            pass.push(lc[randLc])
        } else {
            let randUc = Math.floor(Math.random() * uc.length)
            pass.push(uc[randUc])
        }
    }

    res.json({
        password : pass,
        Length : pass.length
    })

    let flatPass = pass.join("");

    const params = {
        DelaySeconds: 1,
        MessageBody: flatPass.toString(),    
         QueueUrl: process.env.QUE_URL
    }
      
      sqs.sendMessage(params, function(err, data) {
        if (err) {
          console.log("Error", err);
        } else {
          console.log("Success", data.MessageId);
        }
    });
}

// Create a password with numbers, symbols Uppercase and Lowercase letters based on the length from the frontend
const createFullPass = (req,res,next) => {
    const len = req.params.len
    let pass = []

    for (i = 1; i <= len; i++ ) {
        let randChoice = Math.floor(Math.random() * 4)
            if (randChoice === 0) {
                let randNum = Math.floor(Math.random() * nums.length)
                pass.push(nums[randNum])
            } else if (randChoice === 1) {
                let randSym = Math.floor(Math.random() * syms.length)
                pass.push(syms[randSym])
            } else if (randChoice === 2) {
                let randLc = Math.floor(Math.random() * lc.length)
                pass.push(lc[randLc])
            } else {
                let randUc = Math.floor(Math.random() * uc.length)
                pass.push(uc[randUc])
            }
        }
    res.json({
        password : pass,
        Length : pass.length
    })

    let flatPass = pass.join("");

    const params = {
        DelaySeconds: 1,
        MessageBody: flatPass.toString(),    
         QueueUrl: process.env.QUE_URL
    }
      
      sqs.sendMessage(params, function(err, data) {
        if (err) {
          console.log("Error", err);
        } else {
          console.log("Success", data.MessageId);
        }
    });
}

// Create a password with numbers, symbols Uppercase and Lowercase letters based on the length from the frontend with no duplicates
const createFullPassND = (req,res,next) => {
    const len = req.params.len
    let passSet = new Set()
    let passArr = []

    while(passSet.size < len ) {
        let randChoice = Math.floor(Math.random() * 4)
            if (randChoice === 0) {
                let randNum = Math.floor(Math.random() * nums.length)
                passSet.add(nums[randNum])
            } else if (randChoice === 1) {
                let randSym = Math.floor(Math.random() * syms.length)
                passSet.add(syms[randSym])
            } else if (randChoice === 2) {
                let randLc = Math.floor(Math.random() * lc.length)
                passSet.add(lc[randLc])
            } else {
                let randUc = Math.floor(Math.random() * uc.length)
                passSet.add(uc[randUc])
            }
        }

        passArr = [...passSet]

    res.json({
        password : passArr,
        Length : passSet.size
    })

    let flatPass = passArr.join("");

    const params = {
        DelaySeconds: 1,
        MessageBody: flatPass.toString(),    
         QueueUrl: process.env.QUE_URL
    }
      
      sqs.sendMessage(params, function(err, data) {
        if (err) {
          console.log("Error", err);
        } else {
          console.log("Success", data.MessageId);
        }
    });
}

exports.createNoSymPass = createNoSymPass;
exports.createFullPass = createFullPass;
exports.createFullPassND = createFullPassND;
