@echo off
color 0a
cd ..
@echo on
echo Installing dependencies.
haxelib install lime
haxelib install openfl
haxelib install flixel 5.5.0
haxelib install flixel-addons
haxelib install flixel-ui 2.6.3
haxelib install flixel-tools
haxelib install SScript
haxelib install hxCodec 3.0.2
haxelib install tjson 1.0.4
haxelib install hscript-iris 1.0.2
haxelib install hxvlc 2.2.1
haxelib git flxanimate https://github.com/ShadowMario/flxanimate dev
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc
echo Finished!
pause
