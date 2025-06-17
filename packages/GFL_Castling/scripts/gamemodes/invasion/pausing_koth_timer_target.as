// internal
#include "tracker.as"
#include "log.as"

// --------------------------------------------
class PausingKothTimer_Target : Tracker {
	protected GameModeInvasion@ m_metagame;
	protected bool m_started;
	protected float m_time;
	protected bool m_bgm;
	protected bool m_suppress;
    protected array<string> m_targetBaseNames;

	// --------------------------------------------
	PausingKothTimer_Target(GameModeInvasion@ metagame, float time,const array<string>@ baseNames,bool bgm = true,bool suppress = true) {
		super();

		@m_metagame = @metagame;
		m_started = false;
		m_time = time;
		m_bgm = bgm;
		m_suppress = suppress;
        m_targetBaseNames = baseNames;
	}

	// --------------------------------------------
	void start() {
		_log("starting PausingKothTimer", 1);
		m_started = true;
		m_metagame.getComms().send("<command class='set_game_timer' faction_id='0' pause='1' time='" + m_time + "' />");
		if(m_suppress){
			XmlElement command("command");
			command.setStringAttribute("class", "change_game_settings");
			for (uint i = 0; i < m_metagame.getFactions().size(); ++i) {
				if (i != 0) {
					XmlElement faction("faction");
					command.appendChild(faction);
				}
				else {
					XmlElement faction("faction");
					faction.setIntAttribute("disable_enemy_spawnpoints_soldier_count_offset", -100);
					command.appendChild(faction);
				}
			}
			m_metagame.getComms().send(command);
		}
		refresh();
	}

	// --------------------------------------------
	void gameContinuePreStart() {
		// mark as started, to skip calling start()
		// the metagame won't then call start at all
		m_started = true;
	}

	// --------------------------------------------
	void onRemove() {
		// make start() called again if the tracker is added again, like for restart
		m_started = false;
	}

    // ----------------------------------------------------
	protected void refresh() {
        // query about bases
		array<const XmlElement@> baseList = getBases(m_metagame);
		if(m_bgm){
			playSoundtrack(m_metagame,"soundtrack_koth.wav");
		}

		int winner = -1;
        bool ownKeyBase = false;
		for (uint i = 0; i < baseList.size(); ++i) {
			const XmlElement@ base = baseList[i];
            string name = base.getStringAttribute("name");
			if (!base.getBoolAttribute("capturable")) {
				continue;
			}
			for (uint j = 0; j < m_targetBaseNames.size(); ++j) {
				if (name == m_targetBaseNames[j] && base.getIntAttribute("owner_id") == 0) {
					ownKeyBase = true;
					break;
				}
			}

			if (ownKeyBase) {
				break;
			}            
		}

		// pause if someone else holds the capturable base than faction 0
		m_metagame.getComms().send("<command class='set_game_timer' pause='" + (ownKeyBase?0:1) + "' />");
	}

	// ----------------------------------------------------
    protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		refresh();
    }

	// --------------------------------------------
	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return m_started;
	}
}
