webpackJsonp([6],{sX3x:function(t,e,r){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var n=r("mvHQ"),i=r.n(n),u=r("Dod7"),l=r("VCRI"),s={name:"Chapters",data:function(){return{json:"",url:""}},methods:{get:function(t){var e=this;Object(u.a)(t).then(function(t){e.filter(t.data)})},filter:function(t){for(var e=l.load(t)("#list")[0].children[1].children,r=[],n=0;n<e.length;n++){var u={};"dd"==e[n].name&&(u.title=e[n].children[0].children[0].data,u.url=e[n].children[0].attribs.href,r.push(u))}this.json=i()(r)}},mounted:function(){var t=this.$route.query.url;this.url=t,this.get(t)},watch:{$route:{handler:function(t){this.url!=t.query.url&&(this.url=t.query.url,this.get(this.url))}}}},h={render:function(){var t=this.$createElement;return(this._self._c||t)("div",[this._v(this._s(this.json))])},staticRenderFns:[]},a=r("VU/8")(s,h,!1,null,null,null);e.default=a.exports}});
//# sourceMappingURL=6.f6a0f13b4e73b7b3e0bc.js.map