const { spawn } = require("child_process");
const { readFileSync } = require("fs");
const { parse } = require("papaparse");

// Spawn the 'glpsol' process with the '-m' and 'Optimizer.mod' arguments
const process = spawn("glpsol", ["-m", "MILP/Optimizer.mod"]);

process.on("close", (code) => {
    
    const csv = readFileSync("MILP/result.csv", "utf-8");
    
    // Parse the CSV string into an array of objects
    const { data, meta } = parse(csv, { header: true, dynamicTyping: true });
    
    // Convert the array of objects to a JSON string
    const jsonString = JSON.stringify(data);
    
    console.log(jsonString);
    console.log(`\nglpsol process exited with code ${code}`);
});
