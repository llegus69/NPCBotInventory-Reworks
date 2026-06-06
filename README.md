# 🧙 NPCBotInventory

> **WoW WotLK 3.3.5 addon** — Inspect your NPCBots' gear, stats and talent spec at a glance.  
> Addon de WoW WotLK 3.3.5 — Inspecciona el equipo, estadísticas y especialización de tus NPCBots.

---

## 📋 Table of Contents / Índice

- [Features / Características](#-features--características)
- [Installation / Instalación](#-installation--instalación)
- [How it works / Cómo funciona](#-how-it-works--cómo-funciona)
- [Commands / Comandos](#-commands--comandos)
- [Slash Commands](#-slash-commands)
- [Troubleshooting / Solución de problemas](#-troubleshooting--solución-de-problemas)
- [Compatibility / Compatibilidad](#-compatibility--compatibilidad)
- [Author / Autor](#-author--autor)

---

## ✨ Features / Características

### 🇬🇧 English

- **Bot List Panel** — Resizable floating window listing all your NPCBots with their 2D portrait, class icon and talent spec.
- **Paperdoll Inspector** — Full equipment viewer with a large 3D model, all 19 gear slots laid out around it, and item tooltips on hover.
- **Header Info** — Each paperdoll shows the bot's 2D portrait, class icon and talent spec icon side by side.
- **Real Stats Panel** — Displays combat stats received via addon messages (GearScore, Attack Power, Spell Power, Crit, Haste, etc.).
- **Minimap Button** — Draggable minimap button to open/close the bot list. Position is saved between sessions.
- **Floating Toggle Button** — Alternative draggable button. Position is saved between sessions.
- **Persistent Storage** — All inventory and stat data is saved in SavedVariables and restored on login.
- **Help Button** — In-addon `?` button with bilingual (ES/EN) usage instructions.

### 🇪🇸 Español

- **Panel de lista de bots** — Ventana flotante y redimensionable que muestra todos tus NPCBots con su retrato 2D, icono de clase e icono de especialización.
- **Inspector de paperdoll** — Visor completo del equipo con modelo 3D grande, 19 slots de equipo distribuidos alrededor, y tooltips de objeto al pasar el ratón.
- **Info del header** — Cada paperdoll muestra el retrato 2D del bot, el icono de clase y el icono de talento uno al lado del otro.
- **Panel de estadísticas reales** — Muestra las estadísticas de combate recibidas por mensajes de addon (GearScore, Poder de Ataque, Poder de Hechizo, Golpe Crítico, Prisa, etc.).
- **Botón del minimapa** — Botón arrastrable alrededor del minimapa para abrir/cerrar la lista. La posición se guarda entre sesiones.
- **Botón flotante** — Botón alternativo arrastrable. La posición se guarda entre sesiones.
- **Almacenamiento persistente** — Todo el inventario y estadísticas se guardan en SavedVariables y se restauran al iniciar sesión.
- **Botón de ayuda** — Botón `?` integrado con instrucciones de uso en español e inglés.

---

## 📦 Installation / Instalación

### 🇬🇧 English

1. Download the repository as a ZIP or clone it.
2. Place the `NPCBotInventory` folder inside your addons directory:
   ```
   World of Warcraft/Interface/AddOns/NPCBotInventory/
   ```
3. Make sure the folder contains at least:
   ```
   NPCBotInventory.toc
   Core.lua
   UI.lua
   BotInspect.lua
   ```
4. Launch the game and enable the addon in the **Addons** menu on the character selection screen.

### 🇪🇸 Español

1. Descarga el repositorio como ZIP o clónalo.
2. Coloca la carpeta `NPCBotInventory` dentro de tu directorio de addons:
   ```
   World of Warcraft/Interface/AddOns/NPCBotInventory/
   ```
3. Asegúrate de que la carpeta contiene al menos:
   ```
   NPCBotInventory.toc
   Core.lua
   UI.lua
   BotInspect.lua
   ```
4. Lanza el juego y activa el addon en el menú de **Addons** de la pantalla de selección de personaje.

---

## ⚙️ How it works / Cómo funciona

### 🇬🇧 English

The addon works in two layers:

| Layer | What it does |
|-------|-------------|
| **Chat capture** | Listens to `CHAT_MSG_MONSTER_WHISPER` events. When a bot whispers item links or stat lines, they are stored automatically. |
| **Addon messages** | Listens to the `BSTATS` prefix on `CHAT_MSG_ADDON`. The server sends a `STAT;entry;role;...` packet with full combat stats, class and spec. |
| **SavedVariables** | `BotInventoryDB`, `NBIStatsDB`, `NBIRealStatsDB` and `NBIButtonPos` persist everything across sessions. |

### 🇪🇸 Español

El addon funciona en dos capas:

| Capa | Qué hace |
|------|----------|
| **Captura de chat** | Escucha eventos `CHAT_MSG_MONSTER_WHISPER`. Cuando un bot susurra links de objeto o líneas de estadísticas, se almacenan automáticamente. |
| **Mensajes de addon** | Escucha el prefijo `BSTATS` en `CHAT_MSG_ADDON`. El servidor envía un paquete `STAT;entrada;rol;...` con estadísticas de combate completas, clase y especialización. |
| **SavedVariables** | `BotInventoryDB`, `NBIStatsDB`, `NBIRealStatsDB` y `NBIButtonPos` guardan todo entre sesiones. |

---

## 🎮 Commands / Comandos

### Opening the Bot List / Abrir la lista de bots

| Action / Acción | How / Cómo |
|----------------|-----------|
| Open/Close bot list | Click the **minimap button** or the **"Bot Inventory"** floating button |
| Move the minimap button | Drag it around the minimap edge |
| Move the floating button | Drag it anywhere on screen |
| Resize the bot list panel | Drag the **resize handle** (bottom-right corner) |
| Open a bot's paperdoll | Click the 📖 icon on any bot row |

### Updating Bot Data / Actualizar datos del bot

#### 🇬🇧 English
- Make sure the bot is in your **party**.
- Tell the bot: **"show me your inventory"** to refresh item data.
- If stats are missing, **log out and log back in**.

#### 🇪🇸 Español
- Asegúrate de que el bot está en tu **grupo**.
- Dile al bot: **"enséñame tu inventario"** para actualizar los datos de objetos.
- Si las estadísticas no aparecen, **desconéctate y vuelve a iniciar sesión**.

---

## 💬 Slash Commands

```
/botinv              → Toggle bot list panel
/botinv <BotName>    → Open paperdoll for that bot directly
/npcbotinv           → Alias for /botinv
```

---

## 🔧 Troubleshooting / Solución de problemas

### 🇬🇧 English

| Problem | Solution |
|---------|----------|
| Bot list is empty | Make sure the bot has whispered you at least once. Tell them *"show me your inventory"*. |
| Stats panel shows nothing | The bot must be in your party and the server must support `BSTATS` addon messages. Try re-logging. |
| Portrait shows a grey icon | The bot is not currently in your party. Data is still saved from a previous session. |
| Talent icon shows `?` | Spec data hasn't been received yet. Make sure the bot is in your party and stats are loaded. |
| Panel position resets | Saved positions are stored in `NBIButtonPos`. If it was wiped, just drag the buttons to your preferred spot. |

### 🇪🇸 Español

| Problema | Solución |
|----------|----------|
| La lista de bots está vacía | Asegúrate de que el bot te ha susurrado al menos una vez. Dile *"enséñame tu inventario"*. |
| El panel de stats no muestra nada | El bot debe estar en el grupo y el servidor debe soportar mensajes de addon `BSTATS`. Prueba a reloguear. |
| El retrato muestra un icono gris | El bot no está en el grupo en este momento. Los datos del inventario sí se conservan de sesiones anteriores. |
| El icono de talento muestra `?` | Aún no se han recibido datos de especialización. Asegúrate de que el bot está en el grupo y las stats están cargadas. |
| La posición del panel se resetea | Las posiciones se guardan en `NBIButtonPos`. Si se perdieron, simplemente arrastra los botones a su sitio. |

---

## 🧩 Compatibility / Compatibilidad

| | |
|-|-|
| **WoW Version** | WotLK 3.3.5a |
| **NPCBot version** | Compatible with server-side NPCBot implementations that support `BSTATS` addon messages |
| **Other addons** | No known conflicts |

> ⚠️ This addon is designed for **private servers** running a modified WotLK core with NPCBot support. It will not work on retail or official servers.
>
> ⚠️ Este addon está diseñado para **servidores privados** que ejecutan un core WotLK modificado con soporte NPCBot. No funcionará en servidores retail u oficiales.

---

<img width="3840" height="2160" alt="1 4" src="https://github.com/user-attachments/assets/50940429-9b9f-4a0c-b682-41b38147eaf1" />



## 👤 Author / Autor

**Lleguito** — v1.4

> *Built with ☕ and too many late-night raids.*  
> *Hecho con ☕ y demasiadas noches de raid.*

---

<div align="center">

⭐ If this addon helped you, leave a star on the repo! / ¡Si el addon te fue útil, deja una estrella en el repo!

</div>
