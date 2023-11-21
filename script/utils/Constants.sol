// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// Chain IDs
uint256 constant MAINNET = 1;
uint256 constant GOERLI = 5;
uint256 constant HOLESKY = 17000;
uint256 constant SEPOLIA = 11155111;

// Scripty Goerli Contracts
address constant GOERLI_ETHFS_FILE_STORAGE = 0x70a78d91A434C1073D47b2deBe31C184aA8CA9Fa;
address constant GOERLI_SCRIPTY_STORAGE_V2 = 0x4e2f40eef8DFBF200f3f744a9733Afe2E9F83D28;
address constant GOERLI_SCRIPTY_BUILDER_V2 = 0xccd7E419f1EEc86fa748c9079584e3a89312f11C;

// Scripty Sepolia Contracts
address constant SEPOLIA_ETHFS_FILE_STORAGE = 0x2E85be2893d9a0c8B4426DcB7C1359a4e19Dc62A;
address constant SEPOLIA_SCRIPTY_STORAGE_V2 = 0x6683D9DF2e1F3e079cdeCf119C33a88fAd71Db7b;
address constant SEPOLIA_SCRIPTY_BUILDER_V2 = 0x7a165B3e808DfBA9c378c7545EF77E336BF9944e;

// Scripty JS Libraries
string constant CSS_CANVAS_SCRIPT = "fullSizeCanvas.css";
string constant GUNZIP_JS_SCRIPT = "gunzipScripts-0.0.1.js";
string constant INJECT_PNG_SCRIPT = "injectPNGScripts-0.0.1";
string constant P5_JS_SCRIPT = "p5-v1.5.0.min.js.gz";
string constant THREE_JS_GZ_SCRIPT = "three.min.js.gz";
string constant THREE_JS_PNG_SCRIPT = "threejs.min.js.png";

// Scripty Example Scripts
string constant BASE_SCRIPT = "scriptyBase";
string constant CUBE_3D_SCRIPT = "cube3D_GZIP";
string constant DRAW_CIRCLES = "drawCircles";
string constant DRAW_RECTANGLES = "drawRectangles";
string constant DRAW_SHAPES = "drawShapes";
string constant POINTS_AND_LINES_SCRIPT = "pointsAndLines";
string constant STACKED_3D_OBJECTS_1_SCRIPT = "stacked3DObjects1";
string constant STACKED_3D_OBJECTS_2_SCRIPT = "stacked3DObjects2";

// Scripty Custom Tags
bytes constant TAG_OPEN = '<link rel="stylesheet" href="data:text/css;base64,';
bytes constant TAG_CLOSE = '">';

// Splits Mainnet / Goerli Contracts
address constant SPLITS_DEPLOYER = 0x9ebC8E61f87A301fF25a606d7C06150f856F24E2;
address constant SPLITS_MAIN = 0x2ed6c4B5dA6378c7897AC67Ba9e43102Feb694EE;

// Splits Sepolia Contracts
address constant SEPOLIA_SPLITS_MAIN = 0x3E03b08dF74146cA4Dc1f5f5e884228811B5dD6b;

// Creation Code
bytes constant SPLITS_MAIN_CREATION_CODE = hex"60a06040523480156200001157600080fd5b50604051620000209062000054565b604051809103906000f0801580156200003d573d6000803e3d6000fd5b5060601b6001600160601b03191660805262000062565b6103a080620030e983390190565b60805160601c61305362000096600039600081816102b001528181610c1a0152818161106c015261109d01526130536000f3fe6080604052600436106101185760003560e01c806377b1e4e9116100a0578063c7de644011610064578063c7de64401461034e578063d0e4b2f41461036e578063e10e51d61461038e578063e61cb05e146103cb578063ecef0ace146103eb57600080fd5b806377b1e4e91461027e5780638117abc11461029e57806388c662aa146102d2578063a5e3909e1461030e578063c3a8962c1461032e57600080fd5b80633bb66a7b116100e75780633bb66a7b146101cf5780633f26479e146101ef57806352844dd3146102065780636e5f69191461023e5780637601f7821461025e57600080fd5b80631267c6da146101245780631581130214610146578063189cbaa0146101665780631da0b8fc1461018657600080fd5b3661011f57005b600080fd5b34801561013057600080fd5b5061014461013f366004612ab2565b61040b565b005b34801561015257600080fd5b50610144610161366004612c4c565b6104a6565b34801561017257600080fd5b50610144610181366004612ab2565b61081a565b34801561019257600080fd5b506101bc6101a1366004612ab2565b6001600160a01b031660009081526002602052604090205490565b6040519081526020015b60405180910390f35b3480156101db57600080fd5b506101bc6101ea366004612ab2565b6108e5565b3480156101fb57600080fd5b506101bc620f424081565b34801561021257600080fd5b50610226610221366004612d5d565b61093e565b6040516001600160a01b0390911681526020016101c6565b34801561024a57600080fd5b50610144610259366004612d03565b610c4d565b34801561026a57600080fd5b50610226610279366004612ddb565b610d82565b34801561028a57600080fd5b50610144610299366004612c4c565b611144565b3480156102aa57600080fd5b506102267f000000000000000000000000000000000000000000000000000000000000000081565b3480156102de57600080fd5b506102266102ed366004612ab2565b6001600160a01b039081166000908152600260205260409020600101541690565b34801561031a57600080fd5b50610144610329366004612b95565b611487565b34801561033a57600080fd5b506101bc610349366004612c3a565b6117aa565b34801561035a57600080fd5b50610144610369366004612ab2565b61187e565b34801561037a57600080fd5b50610144610389366004612ace565b61194d565b34801561039a57600080fd5b506102266103a9366004612ab2565b6001600160a01b03908116600090815260026020819052604090912001541690565b3480156103d757600080fd5b506101446103e6366004612b95565b611a1f565b3480156103f757600080fd5b50610144610406366004612b06565b611d6f565b6001600160a01b0381811660009081526002602052604090206001015482911633146104515760405163472511eb60e11b81523360048201526024015b60405180910390fd5b6001600160a01b038216600081815260026020819052604080832090910180546001600160a01b0319169055517f6c2460a415b84be3720c209fe02f2cad7a6bcba21e8637afe8957b7ec4b6ef879190a25050565b85858080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525050604080516020808902828101820190935288825290935088925087918291850190849080828437600092019190915250508351869250600211159050610535578251604051630e8c626560e41b815260040161044891815260200190565b8151835114610564578251825160405163b34f351d60e01b815260048101929092526024820152604401610448565b620f424061057183612020565b63ffffffff16146105a75761058582612020565b60405163fcc487c160e01b815263ffffffff9091166004820152602401610448565b82516000190160005b8181101561069e578481600101815181106105db57634e487b7160e01b600052603260045260246000fd5b60200260200101516001600160a01b031685828151811061060c57634e487b7160e01b600052603260045260246000fd5b60200260200101516001600160a01b03161061063e5760405163ac6bd23360e01b815260048101829052602401610448565b600063ffffffff1684828151811061066657634e487b7160e01b600052603260045260246000fd5b602002602001015163ffffffff16141561069657604051630db7e4c760e01b815260048101829052602401610448565b6001016105b0565b50600063ffffffff168382815181106106c757634e487b7160e01b600052603260045260246000fd5b602002602001015163ffffffff1614156106f757604051630db7e4c760e01b815260048101829052602401610448565b50620186a08163ffffffff16111561072a5760405163308440e360e21b815263ffffffff82166004820152602401610448565b61079a8b8a8a8080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525050604080516020808e0282810182019093528d82529093508d92508c9182918501908490808284376000920191909152508b9250612073915050565b61080d8b8b8b8b8080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525050604080516020808f0282810182019093528e82529093508e92508d9182918501908490808284376000920191909152508c92508b91506120c59050565b5050505050505050505050565b6001600160a01b03818116600090815260026020526040902060010154829116331461085b5760405163472511eb60e11b8152336004820152602401610448565b6001600160a01b03808316600081815260026020819052604080832091820180546001600160a01b0319169055600190910154905191931691907f943d69cf2bbe08a9d44b3c4ce6da17d939d758739370620871ce99a6437866d0908490a4506001600160a01b0316600090815260026020526040902060010180546001600160a01b0319169055565b6001600160a01b038116600090815260026020526040812054610909576000610915565b816001600160a01b0316315b6001600160a01b0383166000908152602081905260409020546109389190612f98565b92915050565b6000858580806020026020016040519081016040528093929190818152602001838360200280828437600092019190915250506040805160208089028281018201909352888252909350889250879182918501908490808284376000920191909152505083518692506002111590506109cf578251604051630e8c626560e41b815260040161044891815260200190565b81518351146109fe578251825160405163b34f351d60e01b815260048101929092526024820152604401610448565b620f4240610a0b83612020565b63ffffffff1614610a1f5761058582612020565b82516000190160005b81811015610b1657848160010181518110610a5357634e487b7160e01b600052603260045260246000fd5b60200260200101516001600160a01b0316858281518110610a8457634e487b7160e01b600052603260045260246000fd5b60200260200101516001600160a01b031610610ab65760405163ac6bd23360e01b815260048101829052602401610448565b600063ffffffff16848281518110610ade57634e487b7160e01b600052603260045260246000fd5b602002602001015163ffffffff161415610b0e57604051630db7e4c760e01b815260048101829052602401610448565b600101610a28565b50600063ffffffff16838281518110610b3f57634e487b7160e01b600052603260045260246000fd5b602002602001015163ffffffff161415610b6f57604051630db7e4c760e01b815260048101829052602401610448565b50620186a08163ffffffff161115610ba25760405163308440e360e21b815263ffffffff82166004820152602401610448565b6000610c138a8a8080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525050604080516020808e0282810182019093528d82529093508d92508c9182918501908490808284376000920191909152508b925061239f915050565b9050610c3f7f0000000000000000000000000000000000000000000000000000000000000000826123d5565b9a9950505050505050505050565b60008167ffffffffffffffff811115610c7657634e487b7160e01b600052604160045260246000fd5b604051908082528060200260200182016040528015610c9f578160200160208202803683370190505b50905060008415610cb657610cb38661247a565b90505b60005b83811015610d3257610cff87868684818110610ce557634e487b7160e01b600052603260045260246000fd5b9050602002016020810190610cfa9190612ab2565b6124cd565b838281518110610d1f57634e487b7160e01b600052603260045260246000fd5b6020908102919091010152600101610cb9565b50856001600160a01b03167fa9e30bf144f83390a4fe47562a4e16892108102221c674ff538da0b72a83d17482868686604051610d729493929190612f08565b60405180910390a2505050505050565b600086868080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525050604080516020808a02828101820190935289825290935089925088918291850190849080828437600092019190915250508351879250600211159050610e13578251604051630e8c626560e41b815260040161044891815260200190565b8151835114610e42578251825160405163b34f351d60e01b815260048101929092526024820152604401610448565b620f4240610e4f83612020565b63ffffffff1614610e635761058582612020565b82516000190160005b81811015610f5a57848160010181518110610e9757634e487b7160e01b600052603260045260246000fd5b60200260200101516001600160a01b0316858281518110610ec857634e487b7160e01b600052603260045260246000fd5b60200260200101516001600160a01b031610610efa5760405163ac6bd23360e01b815260048101829052602401610448565b600063ffffffff16848281518110610f2257634e487b7160e01b600052603260045260246000fd5b602002602001015163ffffffff161415610f5257604051630db7e4c760e01b815260048101829052602401610448565b600101610e6c565b50600063ffffffff16838281518110610f8357634e487b7160e01b600052603260045260246000fd5b602002602001015163ffffffff161415610fb357604051630db7e4c760e01b815260048101829052602401610448565b50620186a08163ffffffff161115610fe65760405163308440e360e21b815263ffffffff82166004820152602401610448565b60006110578b8b8080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525050604080516020808f0282810182019093528e82529093508e92508d9182918501908490808284376000920191909152508c925061239f915050565b90506001600160a01b038616611098576110917f000000000000000000000000000000000000000000000000000000000000000082612539565b94506110f5565b6110c17f00000000000000000000000000000000000000000000000000000000000000006125e9565b6001600160a01b03818116600090815260026020526040902060010180546001600160a01b03191691891691909117905594505b6001600160a01b038516600081815260026020526040808220849055517f8d5f9943c664a3edaf4d3eb18cc5e2c45a7d2dc5869be33d33bbc0fff9bc25909190a2505050509695505050505050565b6001600160a01b0388811660009081526002602052604090206001015489911633146111855760405163472511eb60e11b8152336004820152602401610448565b86868080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525050604080516020808a02828101820190935289825290935089925088918291850190849080828437600092019190915250508351879250600211159050611214578251604051630e8c626560e41b815260040161044891815260200190565b8151835114611243578251825160405163b34f351d60e01b815260048101929092526024820152604401610448565b620f424061125083612020565b63ffffffff16146112645761058582612020565b82516000190160005b8181101561135b5784816001018151811061129857634e487b7160e01b600052603260045260246000fd5b60200260200101516001600160a01b03168582815181106112c957634e487b7160e01b600052603260045260246000fd5b60200260200101516001600160a01b0316106112fb5760405163ac6bd23360e01b815260048101829052602401610448565b600063ffffffff1684828151811061132357634e487b7160e01b600052603260045260246000fd5b602002602001015163ffffffff16141561135357604051630db7e4c760e01b815260048101829052602401610448565b60010161126d565b50600063ffffffff1683828151811061138457634e487b7160e01b600052603260045260246000fd5b602002602001015163ffffffff1614156113b457604051630db7e4c760e01b815260048101829052602401610448565b50620186a08163ffffffff1611156113e75760405163308440e360e21b815263ffffffff82166004820152602401610448565b6113f58c8b8b8b8b8b612698565b6114798c8c8c8c80806020026020016040519081016040528093929190818152602001838360200280828437600081840152601f19601f820116905080830192505050505050508b8b808060200260200160405190810160405280939291908181526020018383602002808284376000920191909152508d92508c91506120c59050565b505050505050505050505050565b6001600160a01b0387811660009081526002602052604090206001015488911633146114c85760405163472511eb60e11b8152336004820152602401610448565b86868080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525050604080516020808a02828101820190935289825290935089925088918291850190849080828437600092019190915250508351879250600211159050611557578251604051630e8c626560e41b815260040161044891815260200190565b8151835114611586578251825160405163b34f351d60e01b815260048101929092526024820152604401610448565b620f424061159383612020565b63ffffffff16146115a75761058582612020565b82516000190160005b8181101561169e578481600101815181106115db57634e487b7160e01b600052603260045260246000fd5b60200260200101516001600160a01b031685828151811061160c57634e487b7160e01b600052603260045260246000fd5b60200260200101516001600160a01b03161061163e5760405163ac6bd23360e01b815260048101829052602401610448565b600063ffffffff1684828151811061166657634e487b7160e01b600052603260045260246000fd5b602002602001015163ffffffff16141561169657604051630db7e4c760e01b815260048101829052602401610448565b6001016115b0565b50600063ffffffff168382815181106116c757634e487b7160e01b600052603260045260246000fd5b602002602001015163ffffffff1614156116f757604051630db7e4c760e01b815260048101829052602401610448565b50620186a08163ffffffff16111561172a5760405163308440e360e21b815263ffffffff82166004820152602401610448565b6117388b8b8b8b8b8b612698565b61080d8b8b8b8080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525050604080516020808f0282810182019093528e82529093508e92508d9182918501908490808284376000920191909152508c92508b91506127589050565b6001600160a01b0382166000908152600260205260408120546117ce576000611847565b6040516370a0823160e01b81526001600160a01b0384811660048301528316906370a082319060240160206040518083038186803b15801561180f57600080fd5b505afa158015611823573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906118479190612e6c565b6001600160a01b038084166000908152600160209081526040808320938816835292905220546118779190612f98565b9392505050565b6001600160a01b038181166000908152600260208190526040909120015482911633146118c05760405163472511eb60e11b8152336004820152602401610448565b6001600160a01b03808316600081815260026020819052604080832091820180546001600160a01b0319169055600190910154905133949190911692917f943d69cf2bbe08a9d44b3c4ce6da17d939d758739370620871ce99a6437866d091a4506001600160a01b0316600090815260026020526040902060010180546001600160a01b03191633179055565b6001600160a01b03828116600090815260026020526040902060010154839116331461198e5760405163472511eb60e11b8152336004820152602401610448565b816001600160a01b0381166119c15760405163c369130760e01b81526001600160a01b0382166004820152602401610448565b6001600160a01b03848116600081815260026020819052604080832090910180546001600160a01b0319169488169485179055517f107cf6ea8668d533df1aab5bb8b6315bb0c25f0b6c955558d09368f290668fc79190a350505050565b85858080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525050604080516020808902828101820190935288825290935088925087918291850190849080828437600092019190915250508351869250600211159050611aae578251604051630e8c626560e41b815260040161044891815260200190565b8151835114611add578251825160405163b34f351d60e01b815260048101929092526024820152604401610448565b620f4240611aea83612020565b63ffffffff1614611afe5761058582612020565b82516000190160005b81811015611bf557848160010181518110611b3257634e487b7160e01b600052603260045260246000fd5b60200260200101516001600160a01b0316858281518110611b6357634e487b7160e01b600052603260045260246000fd5b60200260200101516001600160a01b031610611b955760405163ac6bd23360e01b815260048101829052602401610448565b600063ffffffff16848281518110611bbd57634e487b7160e01b600052603260045260246000fd5b602002602001015163ffffffff161415611bed57604051630db7e4c760e01b815260048101829052602401610448565b600101611b07565b50600063ffffffff16838281518110611c1e57634e487b7160e01b600052603260045260246000fd5b602002602001015163ffffffff161415611c4e57604051630db7e4c760e01b815260048101829052602401610448565b50620186a08163ffffffff161115611c815760405163308440e360e21b815263ffffffff82166004820152602401610448565b611cf18a8a8a8080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525050604080516020808e0282810182019093528d82529093508d92508c9182918501908490808284376000920191909152508b9250612073915050565b611d638a8a8a8080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525050604080516020808e0282810182019093528d82529093508d92508c9182918501908490808284376000920191909152508b92508a91506127589050565b50505050505050505050565b6001600160a01b038681166000908152600260205260409020600101548791163314611db05760405163472511eb60e11b8152336004820152602401610448565b85858080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525050604080516020808902828101820190935288825290935088925087918291850190849080828437600092019190915250508351869250600211159050611e3f578251604051630e8c626560e41b815260040161044891815260200190565b8151835114611e6e578251825160405163b34f351d60e01b815260048101929092526024820152604401610448565b620f4240611e7b83612020565b63ffffffff1614611e8f5761058582612020565b82516000190160005b81811015611f8657848160010181518110611ec357634e487b7160e01b600052603260045260246000fd5b60200260200101516001600160a01b0316858281518110611ef457634e487b7160e01b600052603260045260246000fd5b60200260200101516001600160a01b031610611f265760405163ac6bd23360e01b815260048101829052602401610448565b600063ffffffff16848281518110611f4e57634e487b7160e01b600052603260045260246000fd5b602002602001015163ffffffff161415611f7e57604051630db7e4c760e01b815260048101829052602401610448565b600101611e98565b50600063ffffffff16838281518110611faf57634e487b7160e01b600052603260045260246000fd5b602002602001015163ffffffff161415611fdf57604051630db7e4c760e01b815260048101829052602401610448565b50620186a08163ffffffff1611156120125760405163308440e360e21b815263ffffffff82166004820152602401610448565b611d638a8a8a8a8a8a612698565b8051600090815b8181101561206c5783818151811061204f57634e487b7160e01b600052603260045260246000fd5b6020026020010151836120629190612fb0565b9250600101612027565b5050919050565b600061208084848461239f565b6001600160a01b03861660009081526002602052604090205490915081146120be5760405163dd5ff45760e01b815260048101829052602401610448565b5050505050565b6001600160a01b038581166000818152600160209081526040808320948b16808452949091528082205490516370a0823160e01b815260048101949094529092909183916370a082319060240160206040518083038186803b15801561212a57600080fd5b505afa15801561213e573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906121629190612e6c565b9050801561216f57600019015b811561217c576001820391505b818101925081156121b0576001600160a01b038089166000908152600160208181526040808420948e168452939052919020555b836001600160a01b0316886001600160a01b03168a6001600160a01b03167fb5ee5dc3d2c31a019bbf2c787e0e9c97971c96aceea1c38c12fc8fd25c536d46866040516121ff91815260200190565b60405180910390a463ffffffff851615612271576001600160a01b038881166000908152600160205260408120620f424063ffffffff891687020492839290881661224a573361224c565b875b6001600160a01b03168152602081019190915260400160002080549091019055909203915b865160005b81811015612329576122ba858983815181106122a257634e487b7160e01b600052603260045260246000fd5b602002602001015163ffffffff16620f424091020490565b6001600160a01b038b1660009081526001602052604081208b519091908c90859081106122f757634e487b7160e01b600052603260045260246000fd5b6020908102919091018101516001600160a01b0316825281019190915260400160002080549091019055600101612276565b5050801561239457604051633e0f9fff60e11b81526001600160a01b038981166004830152602482018390528a1690637c1f3ffe90604401600060405180830381600087803b15801561237b57600080fd5b505af115801561238f573d6000803e3d6000fd5b505050505b505050505050505050565b60008383836040516020016123b693929190612e84565b6040516020818303038152906040528051906020012090509392505050565b6000611877838330604051723d605d80600a3d3981f336603057343d52307f60681b81527f830d2d700a97af574b186c80d40429385d24241565b08a7c559ba283a964d9b160138201527260203da23d3df35b3d3d3d3d363d3d37363d7360681b6033820152606093841b60468201526d5af43d3d93803e605b57fd5bf3ff60901b605a820152921b6068830152607c8201526067808220609c830152605591012090565b6001600160a01b03811660009081526020819052604081205461249f90600190612fd8565b6001600160a01b0383166000818152602081905260409020600190559091506124c8908261293a565b919050565b6001600160a01b038082166000908152600160208181526040808420948716845293905291812054909161250091612fd8565b6001600160a01b038084166000818152600160208181526040808420958a16845294905292902091909155909150610938908483612990565b6000604051723d605d80600a3d3981f336603057343d52307f60681b81527f830d2d700a97af574b186c80d40429385d24241565b08a7c559ba283a964d9b160138201527260203da23d3df35b3d3d3d3d363d3d37363d7360681b60338201528360601b60468201526c5af43d3d93803e605b57fd5bf360981b605a820152826067826000f59150506001600160a01b0381166109385760405163380bbe1360e01b815260040160405180910390fd5b6000604051723d605d80600a3d3981f336603057343d52307f60681b81527f830d2d700a97af574b186c80d40429385d24241565b08a7c559ba283a964d9b160138201527260203da23d3df35b3d3d3d3d363d3d37363d7360681b60338201528260601b60468201526c5af43d3d93803e605b57fd5bf360981b605a8201526067816000f09150506001600160a01b0381166124c857604051630985da9b60e41b815260040160405180910390fd5b600061270986868080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525050604080516020808a0282810182019093528982529093508992508891829185019084908082843760009201919091525087925061239f915050565b6001600160a01b0388166000818152600260205260408082208490555192935090917f45e1e99513dd915ac128b94953ca64c6375717ea1894b3114db08cdca51debd29190a250505050505050565b6001600160a01b0385166000818152602081905260408120549131908215612781576001830392505b5081810182156127a8576001600160a01b0388166000908152602081905260409020600190555b836001600160a01b0316886001600160a01b03167f87c3ca0a87d9b82033e4bc55e6d30621f8d7e0c9d8ca7988edfde8932787b77b836040516127ed91815260200190565b60405180910390a363ffffffff85161561284c57620f424063ffffffff8616820204806000806001600160a01b0388166128275733612829565b875b6001600160a01b0316815260208101919091526040016000208054909101905590035b865160005b818110156128d25761287d838983815181106122a257634e487b7160e01b600052603260045260246000fd5b6000808b84815181106128a057634e487b7160e01b600052603260045260246000fd5b6020908102919091018101516001600160a01b0316825281019190915260400160002080549091019055600101612851565b5050811561293057604051632ac3affd60e21b8152600481018390526001600160a01b0389169063ab0ebff490602401600060405180830381600087803b15801561291c57600080fd5b505af1158015611479573d6000803e3d6000fd5b5050505050505050565b600080600080600085875af190508061298b5760405162461bcd60e51b815260206004820152601360248201527211551217d514905394d1915497d19052531151606a1b6044820152606401610448565b505050565b600060405163a9059cbb60e01b81526001600160a01b03841660048201528260248201526000806044836000895af19150506129cb81612a0f565b612a095760405162461bcd60e51b815260206004820152600f60248201526e1514905394d1915497d19052531151608a1b6044820152606401610448565b50505050565b60003d82612a2157806000803e806000fd5b8060208114612a39578015612a4a576000925061206c565b816000803e6000511515925061206c565b5060019392505050565b60008083601f840112612a65578182fd5b50813567ffffffffffffffff811115612a7c578182fd5b6020830191508360208260051b8501011115612a9757600080fd5b9250929050565b803563ffffffff811681146124c857600080fd5b600060208284031215612ac3578081fd5b813561187781613005565b60008060408385031215612ae0578081fd5b8235612aeb81613005565b91506020830135612afb81613005565b809150509250929050565b60008060008060008060808789031215612b1e578182fd5b8635612b2981613005565b9550602087013567ffffffffffffffff80821115612b45578384fd5b612b518a838b01612a54565b90975095506040890135915080821115612b69578384fd5b50612b7689828a01612a54565b9094509250612b89905060608801612a9e565b90509295509295509295565b600080600080600080600060a0888a031215612baf578081fd5b8735612bba81613005565b9650602088013567ffffffffffffffff80821115612bd6578283fd5b612be28b838c01612a54565b909850965060408a0135915080821115612bfa578283fd5b50612c078a828b01612a54565b9095509350612c1a905060608901612a9e565b91506080880135612c2a81613005565b8091505092959891949750929550565b60008060408385031215612ae0578182fd5b60008060008060008060008060c0898b031215612c67578081fd5b8835612c7281613005565b97506020890135612c8281613005565b9650604089013567ffffffffffffffff80821115612c9e578283fd5b612caa8c838d01612a54565b909850965060608b0135915080821115612cc2578283fd5b50612ccf8b828c01612a54565b9095509350612ce2905060808a01612a9e565b915060a0890135612cf281613005565b809150509295985092959890939650565b60008060008060608587031215612d18578384fd5b8435612d2381613005565b935060208501359250604085013567ffffffffffffffff811115612d45578283fd5b612d5187828801612a54565b95989497509550505050565b600080600080600060608688031215612d74578081fd5b853567ffffffffffffffff80821115612d8b578283fd5b612d9789838a01612a54565b90975095506020880135915080821115612daf578283fd5b50612dbc88828901612a54565b9094509250612dcf905060408701612a9e565b90509295509295909350565b60008060008060008060808789031215612df3578182fd5b863567ffffffffffffffff80821115612e0a578384fd5b612e168a838b01612a54565b90985096506020890135915080821115612e2e578384fd5b50612e3b89828a01612a54565b9095509350612e4e905060408801612a9e565b91506060870135612e5e81613005565b809150509295509295509295565b600060208284031215612e7d578081fd5b5051919050565b835160009082906020808801845b83811015612eb75781516001600160a01b031685529382019390820190600101612e92565b50508651818801939250845b81811015612ee557845163ffffffff1684529382019392820192600101612ec3565b50505060e09490941b6001600160e01b0319168452505060049091019392505050565b84815260606020808301829052908201849052600090859060808401835b87811015612f54578335612f3981613005565b6001600160a01b031682529282019290820190600101612f26565b5084810360408601528551808252908201925081860190845b81811015612f8957825185529383019391830191600101612f6d565b50929998505050505050505050565b60008219821115612fab57612fab612fef565b500190565b600063ffffffff808316818516808303821115612fcf57612fcf612fef565b01949350505050565b600082821015612fea57612fea612fef565b500390565b634e487b7160e01b600052601160045260246000fd5b6001600160a01b038116811461301a57600080fd5b5056fea264697066735822122078638564d8f0338df6cf15b5c2680d5c2ef45167f59938471977e9756316b94964736f6c6343000804003360a060405234801561001057600080fd5b5033606081901b60805261035461004c60003960008181604b0152818160bc015281816101080152818161013c015261018601526103546000f3fe6080604052600436106100345760003560e01c80630e769b2b146100395780637c1f3ffe14610089578063ab0ebff41461009e575b600080fd5b34801561004557600080fd5b5061006d7f000000000000000000000000000000000000000000000000000000000000000081565b6040516001600160a01b03909116815260200160405180910390f35b61009c6100973660046102d0565b6100b1565b005b61009c6100ac366004610306565b610131565b336001600160a01b037f000000000000000000000000000000000000000000000000000000000000000016146100f9576040516282b42960e81b815260040160405180910390fd5b61012d6001600160a01b0383167f0000000000000000000000000000000000000000000000000000000000000000836101af565b5050565b336001600160a01b037f00000000000000000000000000000000000000000000000000000000000000001614610179576040516282b42960e81b815260040160405180910390fd5b6101ac6001600160a01b037f00000000000000000000000000000000000000000000000000000000000000001682610233565b50565b600060405163a9059cbb60e01b81526001600160a01b03841660048201528260248201526000806044836000895af19150506101ea81610289565b61022d5760405162461bcd60e51b815260206004820152600f60248201526e1514905394d1915497d19052531151608a1b60448201526064015b60405180910390fd5b50505050565b600080600080600085875af19050806102845760405162461bcd60e51b815260206004820152601360248201527211551217d514905394d1915497d19052531151606a1b6044820152606401610224565b505050565b60003d8261029b57806000803e806000fd5b80602081146102b35780156102c457600092506102c9565b816000803e600051151592506102c9565b600192505b5050919050565b600080604083850312156102e2578182fd5b82356001600160a01b03811681146102f8578283fd5b946020939093013593505050565b600060208284031215610317578081fd5b503591905056fea26469706673582212208e095a368bcb2efb2a8afd9b560ad94441e926086a4bc92edf16c33900df798e64736f6c63430008040033";
