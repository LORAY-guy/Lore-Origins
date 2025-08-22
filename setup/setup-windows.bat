@echo off
color 0a
cd ..
@echo on
echo Installing dependencies.
haxelib install lime
haxelib install openfl
haxelib install flixel 5.5.0
haxelib install flixel-addons 3.3.2
haxelib install flixel-ui 2.6.3
haxelib install flixel-tools 1.5.1
haxelib install hxCodec 3.0.2
haxelib install tjson 1.0.4
haxelib install hscript-iris 1.0.2
haxelib install hxvlc 2.2.1
haxelib git flxanimate https://github.com/ShadowMario/flxanimate dev
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib install hxdiscord_rpc 1.2.4
echo Finished!
pause
