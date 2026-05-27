## ✨ Características Principales

### 🛡️ Paperdoll Interactivo Completo
* **19 Ranuras de Equipo:** Ventana visual idéntica a la del personaje principal (cabeza, cuello, hombros, armas, anillos, abalorios, etc.).
* **Carga Dinámica:** Los iconos se rellenan automáticamente detectando el tipo de objeto mediante la API nativa `GetItemInfo`.
* **Calidad de Objetos:** Bordes iluminados con el color correspondiente a su rareza (Gris, Blanco, Verde, Azul, Épico, Legendario).
* **Tooltips Nativos:** Pasa el ratón por encima de cualquier ranura para ver los atributos completos del objeto como si fuera tu propio equipo.

### 📊 Estadísticas Reales del Servidor (Sin Estimaciones)
* **Datos de la Base de Datos:** Las estadísticas provienen directamente de la tabla `characters_npcbot_stats` del servidor en tiempo real. No calcula aproximaciones en base al equipo.
* **Secciones Desplegables:** Organizadas de forma limpia en **Base**, **Ataque (Offence)**, **Defensa (Defence)** y **Resistencias**.
* **Optimización Visual:** La ventana incluye un botón de **Actualizar**. Al presionarlo, los datos se refrescan en segundo plano **sin recargar el modelo 3D del bot**, evitando molestos tirones de pantalla (*lag visual*).

### 👥 Gestión de Escuadra
* **Panel Lateral:** Listado rápido con todos tus bots contratados, indicador de cuántos objetos llevan equipados y acceso directo.
* **Acceso Accesible:** Incluye un botón para el minimapa (con guardado de posición circular) y un botón flotante arrastrable para la pantalla.

### 💾 Persistencia Total
* Los datos de equipo y atributos se almacenan localmente en `SavedVariables`. Podrás consultar qué lleva equipado tu bot **incluso si no está invocado o no forma parte de tu grupo actual**.

---

## 🛠️ Requisitos del Sistema

| Componente | Requisito Técnico |
| :--- | :--- |
| **Servidor** | AzerothCore con el módulo **NPCBots** compilado y activo. |
| **Script del Servidor** | Soporte para **Eluna Lua Engine** (requiere cargar `BotStats_Server.lua`). |
| **Cliente de WoW** | Versión **3.3.5a** (Build 12340). |
| **Dependencias** | Ninguna. Es un Addon 100% independiente (*Standalone*). |

---


## 🚀 Instalación paso a paso

### 1️⃣ Configuración en el Servidor (Eluna)
Mueve el archivo de backend incluido en este repositorio a la carpeta de scripts de tu emulador:


AzerothCore/
└── scripts/
    └── lua_scripts/
        └── BotStats_Server.lua


        Reinicia el servidor o ejecuta el comando .reload eluna en la consola de administración.

💡 Prueba de vida: Entra al juego con tu personaje y escribe .bstats en el chat. Si el script responde con mensajes en pantalla, el sistema de comunicación está listo.

2️⃣ Configuración en el Cliente (Addon)
Extrae la carpeta completa dentro del directorio de interfaz de tu juego:

World of Warcraft/
└── Interface/
    └── AddOns/
        └── NPCBotInventory/
            ├── NPCBotInventory.toc
            ├── Core.lua
            ├── UI.lua
            └── BotInspect.lua

            Reinicia el cliente de World of Warcraft o escribe /reload en el chat si ya estabas dentro.

🕹️ Modo de Uso y Comandos
Cómo interactuar con el panel
🖱️ Clic en el botón del minimapa / flotante: Abre o cierra la lista global de tus bots.

📜 Clic en el pergamino: Abre el visualizador de equipo (paperdoll) de ese bot en específico.

📈 Botón "Stats": Situado bajo el retrato 3D del bot, expande la pestaña de estadísticas avanzadas.

♻️ Botón "Borrar todo": Limpia la caché local de SavedVariables (pide confirmación previa).

Comandos de Chat (Slash Commands)
Puedes utilizar tanto /botinv como el alias /npcbotinv:

/botinv                    # Abre o cierra la interfaz de la lista de bots
/botinv <nombre>           # Abre el paperdoll de un bot específico directamente
/botinv inspect <nombre>   # Acción idéntica a la anterior

📡 Protocolo de Comunicación (Cliente ↔ Servidor)
El addon utiliza los canales ocultos de comunicación de Blizzard para intercambiar estructuras de datos de forma ligera sin sobrecargar el ancho de banda del reino:

sequenceDiagram
    participant Addon as 🖥️ Cliente (Addon WoW)
    participant Servidor as ⚙️ Servidor (Eluna Lua)
    
    Addon->>Servidor: SendAddonMessage("BSTATS", "REQUEST")
    Note over Servidor: Consulta DB interna de los NPCBots
    Servidor->>Addon: AddonMessage("STAT;entry;hp;mp;str;...") [Línea por Bot]
    Servidor->>Addon: AddonMessage("END")
    Note over Addon: Guarda los datos en NBIRealStatsDB

    El Addon intercepta el evento del sistema CHAT_MSG_ADDON bajo el prefijo único BSTATS.

📂 Arquitectura de Archivos

NPCBotInventory.toc — Manifiesto del addon, configuración de carga e información de lectura para el juego.

Core.lua — Gestor de datos raíz, control de SavedVariables y receptor de los mensajes del servidor.

UI.lua — Construcción del panel de la lista de bots, botón del minimapa y botón flotante interactivo.

BotInspect.lua — Maquetación del Paperdoll (slots), tooltips de items y ventana de atributos detallados.

BotStats_Server.lua — Script de Servidor. Lógica en lenguaje Lua para Eluna que extrae los datos de la base de datos SQL del servidor.

💾 Estructura de Datos Guardados

El addon registra la información de manera local en la carpeta WTF mediante las siguientes tablas internas:

BotInventoryDB ➡️ Almacena los strings estructurados (ItemLinks) de los objetos equipados de cada bot vinculados a tu cuenta.

NBIStatsDB ➡️ Guarda el GearScore total calculado a través del canal de susurros del bot.

NBIRealStatsDB ➡️ Caché offline con todas las estadísticas crudas enviadas por el script de Eluna.

NBIButtonPos ➡️ Coordenadas X/Y del botón flotante y el ángulo en grados del botón del minimapa.

<img width="1366" height="705" alt="Wow 2026-05-27 10-15-38" src="https://github.com/user-attachments/assets/0029b3a0-4ce8-470a-b226-c72b8f49e163" />


