function test(name,callback){
  callback("hello,"+name)
}

function add(a,b){
  return a+b
}

function a() {
  var request = new XMLHttpRequest();
  request.open("GET", "https://jquil.github.io/api/music/test.js?t=1700893076392", false);
  request.send(null);
  if (request.status === 200) {
      return (request.responseText);
  }
  return ""
}
