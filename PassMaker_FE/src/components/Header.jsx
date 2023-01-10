import React from 'react';
import classes from './Header.module.css';


const Header = () => {
    return (
        <div className={classes.headerStruct}>
            <div >
                <p className={classes.header}>Password Maker</p>
                <p className={classes.lowHeader}>Create and save complex passwords</p>
            </div>
         </div>
    )
}

export default Header;