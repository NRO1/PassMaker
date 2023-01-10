const express = require('express');
const router = express.Router()
const passController = require('../controllers/maker-controller')

router.get('/:len', passController.createNoSymPass) //sym = false
router.get('/:len/full', passController.createFullPass)//sym ==true ND ==false
router.get('/:len/fullnd', passController.createFullPassND)//sym = true nd= true

module.exports = router;


