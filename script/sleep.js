function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
console.log("sleep");
sleep(process.argv[2]);