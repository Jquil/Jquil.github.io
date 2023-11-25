function test(name,callback){
  callback("hello,"+name)
}

function add(a,b){
  return a+b
}

function a() {
  return fetch("https://jquil.github.io/api/music/test.js?t=1700893076392")
}
