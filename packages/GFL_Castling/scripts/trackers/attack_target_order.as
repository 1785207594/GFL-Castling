// internal
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

// assuming that base capturing is set up so that side base captures don't happen
// Original Author: RWR WW2 DLC Author

// --------------------------------------------
class AttackTargetOrder : Tracker {
	protected Metagame@ m_metagame;
	protected int m_factionId;

	protected array<string> m_order;

	protected bool m_started;

	// ----------------------------------------------------
	AttackTargetOrder(Metagame@ metagame, int factionId, const array<string>@ order) {
		@m_metagame = @metagame;
		m_factionId = factionId;
		m_order = order;
		m_started = false;
	}

	// ----------------------------------------------------
	bool hasStarted() const {
		return m_started;
	}

	// ----------------------------------------------------
	bool hasEnded() const {
		return false;
	}
	
	// ----------------------------------------------------
	void start() {
		m_started = true;

		refresh();
	}
	
	// ----------------------------------------------------
	void gameContinuePreStart() {
		m_started = true;
	}

	// ----------------------------------------------------
	void onRemove() {
		m_started = false;
	}
		
	// ----------------------------------------------------
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		//if (event.getIntAttribute("owner_id") != m_factionId) return;
		_log("AttackTargetOrder, handleBaseOwnerChangeEvent, faction=" + m_factionId, 1);
		
		refresh();
	}
	
	// ----------------------------------------------------
	protected void refresh() {
		_log("AttackTargetOrder, refresh, faction=" + m_factionId, 1);
		array<const XmlElement@> bases = getBasesForFaction(m_factionId);

		bool handled = false;

		int farthestOwned = -1;
		for (uint i = 0; i < bases.size(); ++i) {
			const XmlElement@ base = bases[i];
			string baseKey = base.getStringAttribute("key");
			
			int index = m_order.find(baseKey);
			if (index >= 0) {
				if (index > farthestOwned) {
					farthestOwned = index;
				}
			} else {
				_log("WARNING, owned base " + baseKey + " not found in order list");
			}
		}
		
		if (farthestOwned >= 0) {
			uint next = farthestOwned + 1;
				if (next < m_order.size()) {
					attackTo(m_order[next]);
					handled = true;
			}
		}
		
		if (!handled) {
			// clear attack if no base found
			attackTo("");
		}
	}
	
	// ----------------------------------------------------
	protected void attackTo(string baseKey) {
		_log("AttackTargetOrder, attackTo, faction=" + m_factionId + ", baseKey=" + baseKey, 1);
		XmlElement command("command");
		command.setStringAttribute("class", "commander_ai");
		command.setIntAttribute("faction", m_factionId);
		command.setStringAttribute("attack_target_base_key", baseKey);
		m_metagame.getComms().send(command);
	}

    // ----------------------------------------------------
	protected array<const XmlElement@> getBasesForFaction(int factionId) {
		array<const XmlElement@> result;
		array<const XmlElement@> baseList = getBases(m_metagame);
		// go through list of bases
		for (uint i = 0; i < baseList.size(); ++i) {
			const XmlElement@ base = baseList[i];
			if (base.getIntAttribute("owner_id") == factionId) {
				result.insertLast(base);
			}
		}
		return result;
	}
}
