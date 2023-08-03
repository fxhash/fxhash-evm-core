# Project user flows

These are the main flows artist will take when publishing their projects.

## Distribution settings (reserves, pricing, etc...)

These are the various flow outlining various distribution settings artists can use.

- 100eds, fixed price for everyone
- 100eds, fixed price for everyone, opens at a given time
- 100eds, dutch auction for everyone
- 100eds, dutch auction for everyone, 20eds reserved with access list
- 100eds, dutch auction for everyone, 20eds reserved with access list, 10 eds reserved with another access list
- 100eds, 20 eds with access list on dutch auction, 80 eds to the public at fixed pricing
- opens editions, dutch auction for everyone
- 100eds, dutch auction for everyone, 20eds reserved with access list; when the 80 public eds are minted, price of the dutch auction is locked to its current amount
- open editions, 50 access list which have to mint at a fixed price before the public can start minting, with a dutch auction
- for all of the above, support of mint tickets

Optionnaly, we also want to think about how we can grant another account the right to run Gate operations in our name. Ex:

- 100eds, access list, fixed price
- user A has an access list slot
- user A want to pay with credit card
  - our credit card solution involves having them make a blockchain transaction in the background with their wallet
- user A grants credit card provider the right to consume their reserve slot
- credit card provider mints on behalf of user A

## Project settings

### Onchain code

The snippet must always be declared as a dependency. Its content is in [./onchain-code/snippet.js](./onchain-code/snippet.js).

For a simple test project the following code may be used:

```
(()=>{function n(){const e=$fx.getParam("color_id").hex.rgba,a=(t=e.replace("#",""),(parseInt(t,16)>>16&255)>170?"#000000":"#ffffff");var t;document.body.style.background=e,document.body.innerHTML=`\n  <div style="color: ${a};">\n    <p>\n    hash: ${$fx.hash}\n    </p>\n    <p>\n    minter: ${$fx.minter}\n    </p>\n    <p>\n    iteration: ${$fx.iteration}\n    </p>\n    <p>\n    inputBytes: ${$fx.inputBytes}\n    </p>\n    <p>\n    context: ${$fx.context}\n    </p>\n    <p>\n    params:\n    </p>\n    <pre>\n    ${$fx.stringifyParams($fx.getRawParams())}\n    </pre>\n  <div>\n  `;const r=document.createElement("button");r.textContent="emit random params",r.addEventListener("click",(()=>{$fx.emit("params:update",{number_id:$fx.getRandomParam("number_id"),color_id:$fx.getRandomParam("color_id"),bytes_id:$fx.getRandomParam("bytes_id")}),n()})),document.body.appendChild(r)}new URLSearchParams(window.location.search),$fx.params([{id:"number_id",name:"A number/float64",type:"number",update:"code-driven",options:{min:1,max:10,step:1e-4}},{id:"color_id",name:"A color",type:"color",update:"code-driven"},{id:"bytes_id",name:"Big bytes param",type:"bytes",update:"code-driven",options:{length:8192}}]),$fx.features({"A random feature":Math.floor(10*$fx.rand()),"A random boolean":$fx.rand()>.5,"A random string":["A","B","C","D"].at(Math.floor(4*$fx.rand())),"Feature from params, its a number":$fx.getParam("number_id")}),n(),$fx.on("params:update",(n=>5!==n.number_id),((e,a)=>n()))})();
```

### Offchain code

This is an IPFS pointer to the JSON metadata of a test project: `ipfs://Qmdj4mUAG2UxJAnNhqHZkqEpu5G4g8aZ4evgMyeySnaRzD`

It can be viewed here: https://gateway.fxhash-dev2.xyz/ipfs/Qmdj4mUAG2UxJAnNhqHZkqEpu5G4g8aZ4evgMyeySnaRzD

The code is behind this ipfs URI: ipfs://QmdF19947fuCQKbaHpfZoPF6L6yeNGRs2PASdJrMEtiwbh (which is included inside the whole JSON metadata)
