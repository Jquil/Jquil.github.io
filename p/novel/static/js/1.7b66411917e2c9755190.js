webpackJsonp([1],{Zwuv:function(t,e,r){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var n=r("Dod7"),i=r("VCRI"),l={name:"SoftRes",data:function(){return{json:"",url:""}},methods:{get:function(t){var e=this;Object(n.d)(t).then(function(t){e.filter(t.data)})},filter:function(t){for(var e=i.load(t),r=[],n=e(".bookbox"),l=0;l<n.length;l++){var h={};h.title=e(n)[l].children[3].children[0].children[0].children[0].children[0].data,h.url=e(n)[l].children[1].childNodes[0].attribs.href,h.pic=e(n)[l].children[1].childNodes[0].children[0].attribs.src,h.author=e(n)[l].children[3].children[1].children[0].data,h.desc=e(n)[l].children[3].children[7].children[1].data,r.push(h)}var d={};d.hot=r,this.json=d}},mounted:function(){var t=this.$route.query.url;this.url=t,this.get(t)},watch:{$route:{handler:function(t){this.url!=t.query.url&&(this.url=t.query.url,this.get(this.url))}}}},h={render:function(){var t=this.$createElement;return(this._self._c||t)("div",[this._v(this._s(this.json))])},staticRenderFns:[]},d=r("VU/8")(l,h,!1,null,null,null);e.default=d.exports}});
//# sourceMappingURL=1.7b66411917e2c9755190.js.map