var _request = require("request");
var _fs = require("fs");
var util = require("util");
var exec = require('child_process').exec,child;

var req = _request.defaults({jar:true});

var FileCookieStore = require('tough-cookie-filestore');
// NOTE - currently the 'cookies.json' file must already exist!
var j = req.jar()
//req.jar(new FileCookieStore('cookies.json'));


var options = {
  url: 'http://v2.qun.hk/',
  headers: {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.63 Safari/537.36'
  },
  jar:j
};

var _globalPage = 1;

var _url_frontPage = "http://v2.qun.hk/";

var _url_checkpone = "http://v2.qun.hk/v1/oauth/checkphone";

var _url_logon = "http://v2.qun.hk/v1/oauth/loginbypassword";

var _url_getdefaultCard = "http://v2.qun.hk/v1/card/getdefaultcard";

var _url_getphonebook = "http://v2.qun.hk/v1/phonebook/members?keyword=&page=%s&id=a5228e577687"

var logonData ;

var resultDir = "./results";

function init()
{
	 _fs.stat(resultDir, (err)=>{
		if(!err)
		{
			//dir exist; then no error
			
			child = exec('rm -rf ' + resultDir,function(err,out) { 
					_fs.mkdirSync(resultDir);
					checkphone();
				});
		} 
		else
		{
			//dir not exist, then error == null
			_fs.mkdirSync(resultDir);
			checkphone();
		}
	});
}

function checkphone()
{
	// options.url = _url_frontPage
	// req(options,function (err,resp,body) {
	// 	if(err){
	// 		console.log("checkphone 1 error,",err);
	// 		return;
	// 	}
		options.url = _url_checkpone;
		options.formData = {"phone":"18578610193"};
		console.log(options);
		req.post(options,function (err,resp,body) {
			if(err){
				console.log("checkphone 2 error,",err);
				return;
			}
			console.log("checkphone",body);
			logon();
		});
	// });
	
}

function logon()
{
	options.url = _url_logon;
	options.formData = {"username":"18578610193","password":"eric0219"};
	req.post(options,
			function(err,resp,body){
				console.log("logon",body);
				logonData = eval("("+body+")");
				console.log(j);
				console.log(logonData);
				var cookie = req.cookie("auth.token="+logonData.authorize.token);
				j.setCookie(cookie,_url_frontPage)
				cookie = req.cookie("auth.user_id="+logonData.authorize.user_id);
				j.setCookie(cookie,_url_frontPage)
				cookie = req.cookie("auth.expires_in="+logonData.authorize.expires_in);
				j.setCookie(cookie,_url_frontPage)
				cookie = req.cookie("auth.platform="+logonData.authorize.platform);
				j.setCookie(cookie,_url_frontPage)
				options.headers.Authorization = "Bearer " + logonData.authorize.token
				getDefaultCard();
			})
}

function getDefaultCard(){
	options.url = _url_getdefaultCard;
	options.formData = {};
	req(options,
			function(err,resp,body){
				console.log("getDefaultCard",body);
				console.log(j);
				getPhonebookMember(_globalPage);
			})
}
function getPhonebookMember(page)
{
	var url = util.format(_url_getphonebook,page);
	options.url = url; 
	req(options,function(err,resp,body){ 
		if(err){
			console.log("Request Error:",err);
			return;
		}
		//console.log(j);
		var jsonObj = eval("(" + body + ")");
		_globalPage = jsonObj.next;
		_fs.writeFile(util.format("./results/page%s.txt",page),body,function(error) {
			if(error){
				console.log("Write File Error:",error);
			}else{
				if(_globalPage != -1) {
					getPhonebookMember(_globalPage);	
				}
			}
		})
	 });
}

init();
 
