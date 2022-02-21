import { Box, Paper, Typography, Grid } from '@mui/material';
import * as React from 'react';
import { useEffect, useState } from 'react';
import tempImage from "./assets/images/temp.png"
import phImage from "./assets/images/ph.png"
import ntuImage from "./assets/images/ntu.png"
import { AlignHorizontalRightRounded } from '@mui/icons-material';



export default function LiveDataCard() {

    const [temperature, setTemperature] = useState(-1)
    const fetchTemperature = async () => {
        const result = await fetch("example.com")
        const data: number = await result.json()
        setTemperature(data)
    }

    const [ntu, setNtu] = useState(-1)
    const fetchNtu = async () => {
        const result = await fetch("example.com")
        const data: number = await result.json()
        setNtu(data)
    }

    const [phValue, setPhValue] = useState(-1)
    const fetchPhValue = async () => {
        const result = await fetch("example.com")
        const data: number = await result.json()
        setPhValue(data)
    }

    const [movement, setMovement] = useState(-1)
    const fetchMovement = async () => {
        const result = await fetch("example.com")
        const data: number = await result.json()
        setMovement(data)
    }

    useEffect(() => {
        /* setInterval(fetchTemperature,500) */
        /* setInterval(fetchNtu,500) */
        /* setInterval(fetchPhValue,500) */
        /* setInterval(fetchMovement,500) */
    }, [])





    return (
        <Grid container spacing= {2}  >
            <Grid item xs={12}>
                <Paper style={{ height: 100, width: 300, flex: 1, justifyContent: 'center', alignItems: 'center' }}>
                
                    <Typography fontFamily="Poppins" fontSize="40" style={{ flex: 1, justifyContent: 'center', alignItems: 'center',paddingTop:20}}>
                    <img src={tempImage} style={{ height: 70, width: 70, }} />
                        Temperature = {temperature}°
                    </Typography>

                </Paper>

            </Grid>

            <Grid item xs={12}>
                <Paper style={{ height: 100, width: 300, padding: 10 }}>
                    <Typography fontFamily="Poppins" fontSize="40" style={{ flex: 1, justifyContent: 'center', alignItems: 'center',paddingTop:10}}>
                        <img src={ntuImage} style={{ height: 70, width: 70, }} />
                        NTU = {ntu}
                    </Typography>
                </Paper>
            </Grid>

            <Grid item xs={12}>
                <Paper style={{ height: 100, width: 300,  }}>
                    <Box alignItems="center">
                        
                        <Typography fontFamily="Poppins" fontSize="40" fontStyle="bold" style={{ flex: 1, justifyContent: 'center', alignItems: 'center', marginLeft:10}}>
                        <img src={phImage} style={{ height: 80, width: 60,}} />
                        Ph-Wert = {phValue}
                        </Typography>
                    </Box>
                </Paper>
            </Grid>

            <Grid item xs={12}>
                <Paper style={{ height: 100, width: 300, marginRight:"200px" }}>
                    <Box alignItems="center">
                        
                        <Typography fontFamily="Poppins" fontSize="40" fontStyle="bold" style={{ flex: 1, justifyContent: 'center', alignItems: 'center',paddingTop:10}}>
                        
                        Bewegungsdaten {movement}
                        </Typography>
                    </Box>
                </Paper>
            </Grid>

        </Grid>
        



    );
};
