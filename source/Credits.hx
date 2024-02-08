package;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end
import haxe.Json;

typedef CreditsData =
{
	step:Int,
	skip:Bool
}

class Credits
{
    public static function getCreditsFile(song:String):CreditsData {
		var rawJson:String = null;
		var path:String = Paths.json(song + '/credits');

		#if MODS_ALLOWED
		var modPath:String = Paths.modsJson(song + '/credits');
		if(FileSystem.exists(modPath)) {
			rawJson = File.getContent(modPath);
		} else if(FileSystem.exists(path)) {
			rawJson = File.getContent(path);
		}
		#else
		if(Assets.exists(path)) {
			rawJson = Assets.getText(path);
		}
		#end
		else
		{
			return null;
		}
		return cast Json.parse(rawJson);
	}

	public static function dummy() {
		return {
			step: 0,
			skip: false
		};
	}
}