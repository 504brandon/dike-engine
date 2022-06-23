package mods;

#if polymod
import polymod.format.ParseRules;
#end

/**
    Class for loading mods with `Polymod`.
**/
class ModLoader
{
    public static var mod_dirs:Array<String> = [];

	public static function reloadMods()
	{
		#if polymod
        polymod.PolymodConfig.modMetadataFile = "mod.json";
        polymod.PolymodConfig.modIconFile = "mod.png";

		mod_dirs = [];

		for(meta in polymod.Polymod.scan("mods"))
		{
			mod_dirs.push(meta.id);
		}

        if(!ui.PreferencesMenu.getPref("mods"))
            mod_dirs = [];

        var parse_rules:ParseRules = ParseRules.getDefault();
        parse_rules.addFormat("json", new CustomJSONParse());

        polymod.Polymod.init({
			modRoot: "mods",
			dirs: mod_dirs,
			framework: OPENFL,
			errorCallback: function(error:polymod.Polymod.PolymodError)
			{
				#if debug
				trace(error.message);
				#end
			},
			frameworkParams: {
				assetLibraryPaths: [
					"songs" => "songs",
					"shared" => "shared",
                    "tutorial" => "tutorial",
					"week1" => "week1",
					"week2" => "week2",
					"week3" => "week3",
					"week4" => "week4",
					"week5" => "week5",
					"week6" => "week6",
					"week7" => "week7"
				]
			},
            parseRules: parse_rules
		});
		#end
	}
}