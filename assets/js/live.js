// JS & CSS shared with non_live pages
import "./common"

// import LiveView etc
import "./vendor/liveview"

// Extensions... 
// TODO: make this more modular/configurable

import { ExtensionHooks } from "../../deps/bonfire_geolocate/assets/js/extension" 
Object.assign(window.liveSocket.hooks, ExtensionHooks);
