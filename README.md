# NPCBotInventory

> Addon para **AzerothCore + NPCBots** (WotLK 3.3.5) que muestra el equipo y las estadísticas reales de tus bots contratados con un paperdoll interactivo.

**Autor:** Lleguito · **Versión:** 3.0 · **Parche:** 3.3.5 (Interface 30300)

---

## Características

### Paperdoll interactivo
- Ventana de equipo estilo paperdoll con los 19 slots (cabeza, cuello, hombros, armas, anillos, etc.)
- Los iconos se rellenan automáticamente detectando el tipo de cada item (`GetItemInfo`)
- Borde de calidad en color (gris, verde, azul, épico, legendario) en cada slot
- Tooltip nativo de WoW al pasar el ratón sobre cualquier item equipado

### Estadísticas reales del servidor
- Ventana secundaria de stats bajo demanda: se abre pulsando el botón **Stats** en el paperdoll
- Las estadísticas provienen directamente de `characters_npcbot_stats` en tiempo real, **no son estimaciones** calculadas a partir de los items
- Stats organizadas en secciones: **Base · Offence · Defence · Resistances**
- Botón **Actualizar** para refrescar los datos sin cerrar la ventana
- El retrato 3D del bot **no se recarga** al pedir las stats (se evita el lag visual)

### Lista de bots
- Panel lateral con todos los bots contratados, contador de items por bot e icono de acceso directo al paperdoll
- Botón en el minimapa arrastrable (guarda su posición entre sesiones)
- Botón flotante arrastrable como alternativa al minimapa

### Persistencia
- El equipo y las stats se guardan en `SavedVariables` y están disponibles aunque el bot no esté en el grupo
- Los datos persisten entre sesiones de juego

---

## Requisitos

| Componente | Detalle |
|---|---|
| Servidor | AzerothCore con el módulo **NPCBots** instalado |
| Script servidor | `BotStats_Server.lua` cargado en Eluna (incluido en este repo) |
| Cliente | WoW **3.3.5a** (build 12340) |
| Dependencias de addon | Ninguna |

---

## Instalación

### 1 · Script de servidor (Eluna)

Copia `BotStats_Server.lua` en la carpeta de scripts Lua de tu servidor:

```
AzerothCore/
└── scripts/
    └── lua_scripts/
        └── BotStats_Server.lua
```

Reinicia el servidor (o recarga los scripts con `.reload eluna` si tu build lo soporta).

> **Comprobación:** escribe `.bstats` en el chat de tu personaje. Si ves mensajes en pantalla el script está activo.

### 2 · Addon de cliente

Copia la carpeta `NPCBotInventory` completa en el directorio de addons de WoW:

```
World of Warcraft/
└── Interface/
    └── AddOns/
        └── NPCBotInventory/
            ├── NPCBotInventory.toc
            ├── Core.lua
            ├── UI.lua
            └── BotInspect.lua
```

Reinicia WoW o escribe `/reload` en el chat.

---

## Uso

### Abrir el panel de bots

| Método | Acción |
|---|---|
| Clic en el **botón del minimapa** | Abre / cierra la lista de bots |
| Clic en el **botón flotante** "Bot Inventory" | Abre / cierra la lista de bots |
| `/botinv` | Abre / cierra la lista de bots |

### Ver el equipo de un bot (paperdoll)

1. Abre la lista de bots.
2. Haz clic en el icono de pergamino 📜 junto al nombre del bot.
3. O escribe `/botinv inspect <nombre>`.

### Ver las estadísticas reales

1. Abre el paperdoll del bot.
2. Pulsa el botón **Stats** que aparece debajo del retrato.
3. Se abre la ventana de estadísticas con los datos actuales del servidor.
4. Pulsa **Actualizar** para refrescar en cualquier momento.

### Borrar datos guardados

- Abre la lista de bots y pulsa **Borrar todo** (pide confirmación).
- O escribe `/botinv` y usa el botón en el panel.

### Comandos slash

```
/botinv                    → Abre / cierra la lista de bots
/botinv <nombre>           → Abre el paperdoll de ese bot directamente
/botinv inspect <nombre>   → Igual que el anterior
/npcbotinv                 → Alias de /botinv
```

---

## Cómo funciona la comunicación cliente ↔ servidor

```
[Addon]  →  SendAddonMessage("BSTATS", "REQUEST")  →  [Servidor Eluna]
[Servidor]  →  AddonMessage "STAT;entry;hp;mp;str;..."  →  [Addon]   (una línea por bot)
[Servidor]  →  AddonMessage "END"                        →  [Addon]
```

El addon escucha el evento `CHAT_MSG_ADDON` con prefijo `BSTATS`. Las estadísticas se guardan en `SavedVariables` (`NBIRealStatsDB`) para estar disponibles offline.

---

## Estructura de archivos

```
NPCBotInventory/
├── NPCBotInventory.toc   — Manifiesto del addon
├── Core.lua              — Lógica de datos, SavedVariables, listener de AddonMessage
├── UI.lua                — Lista de bots, botón de minimapa, botón flotante
└── BotInspect.lua        — Ventana paperdoll y ventana de estadísticas

BotStats_Server.lua       — Script Eluna (va en el servidor, no en el cliente)
```

---

## SavedVariables

| Variable | Contenido |
|---|---|
| `BotInventoryDB` | Links de items equipados por bot y personaje |
| `NBIStatsDB` | GearScore recibido por whisper del bot |
| `NBIRealStatsDB` | Estadísticas reales recibidas del servidor |
| `NBIButtonPos` | Posición del botón flotante y ángulo del botón de minimapa |

---

## Créditos

Desarrollado por **Lleguito** para servidores privados AzerothCore con el módulo NPCBots.  
El script de servidor (`BotStats_Server.lua`) se inspira en la arquitectura de comunicación de **BotManagerUI** de su autor original.

<img width="3840" height="2160" alt="Wow 2026-05-28 18-40-23" src="https://github.com/user-attachments/assets/e2e2729a-1615-4875-befb-0b77264ef1fc" />


