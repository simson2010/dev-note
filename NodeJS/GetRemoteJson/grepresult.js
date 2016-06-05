var fs = require("fs");
var util = require("util");

var start_num = 1;
var end_num = 405;

var filePattern = "page%s.txt";

var globalPage = start_num;

var resultFile = "cards.csv";

function initFile(){
	var pathToFile = "./" + resultFile;
	var isExists = fs.existsSync(pathToFile);
	var isDeleted = false;
	if(isExists)
	{
		try{
			fs.unlinkSync(pathToFile);
		}catch(E){
			console.log("initFile->delete error,",E);
			return;
		}
	}
	fs.writeFile(pathToFile, '"company","realname","position","phone"\r\n','utf8',function(err){
		if(err){
			console.log("initFile error,",err);
			return;
		}
		readFileFromDisk(globalPage);
	});
}
function readFileFromDisk(page){
	var filenameAndPath = "./results/" + util.format(filePattern,page);
	fs.readFile(filenameAndPath, function(err,data) {
		var jsonObj = eval("(" + data + ")");
		appendToFullList(jsonObj);
	})
}

function appendToFullList(jsonData) {
	var list = jsonData.list;

	for(var i = 0;i<list.length;i++){
		var member = list[i];
		var card = member.card;
		writeDetailToFullList(card);
	}
	if(globalPage<end_num){
		globalPage++;
		readFileFromDisk(globalPage);
	}
	
}

function writeDetailToFullList(card){
	var filename = "./cards.csv"
	var dataToBeWrite = util.format("\"%s\",\"%s\",\"%s\",\"%s\"\r\n",card.company,card.realname,card.position,card.phone);
	fs.appendFile(filename,dataToBeWrite,'utf8',function(err){
		if(err){
			console.log("writeDetailToFullList",err);
			return;
		}
	})
}

initFile();

