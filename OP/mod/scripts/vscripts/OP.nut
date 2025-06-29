global function OP_Init

string OPVersion = "1.0.2"

void function OP_Init() {
    AddClientCommandCallback("se_cheats", ClientCommand_se_cheats)
    //AddClientCommandCallback("ServerCommand", ClientCommand_ServerCommand)
    AddClientCommandCallback("OPVersion", ClientCommand_OPVersion)
    AddClientCommandCallback("GameRules_ChangeMap", ClientCommand_GameRules_ChangeMap)
    AddClientCommandCallback("TP", ClientCommand_TP)
    AddClientCommandCallback("Player", ClientCommand_Player)
    AddClientCommandCallback("Die", ClientCommand_Die)
    AddClientCommandCallback("OP", ClientCommand_OP)

    AddClientCommandCallback( "GetOrigin", ClientCommand_OP_GetOrigin )
    AddClientCommandCallback( "GetAngles", ClientCommand_OP_GetAngles )

    //AddClientCommandCallback( "wwssadadba", wwssadadba )
}

void function OP_ChatServerPrivateMessage(entity player, string message) {
    Chat_ServerPrivateMessage(player, "\x1b[31m" + "[OP]" + "\x1b[0m" + "\x1b[32m" + "[v" + OPVersion + "]" + "\x1b[0m" + "\x1b[33m" + message + "\x1b[0m", false, false)
}

bool function isOP(int UID) {
    string opList = GetConVarString("OP_UIDS")
    array<string> OPS = split(opList, ",")
    foreach (OPUID in OPS) {
        if (OPUID != "" && OPUID.tointeger() == UID) {
            return true
        }
    }
    return false
}

string function join_strings(array<string> list, string separator) {
    string result = ""
    for (int i = 0; i < list.len(); i++) {
        if (i > 0) {
            result += separator
        }
        result += list[i]
    }
    return result
}



bool function wwssadadba( entity player, array<string> args ){
    thread KonamiCode(player)
	return true
}
void function KonamiCode(entity player) {
    string id = UniqueString("votes#")
    NSCreateStatusMessageOnPlayer( player , "Konami Code" , "" , id )
    wait 3.0
    NSDeleteStatusMessageOnPlayer( player , id )
}

bool function ClientCommand_OP_GetAngles( entity player, array<string> args ){
	OP_ChatServerPrivateMessage( player, "Angles："+player.GetAngles() )
	return true
}

bool function ClientCommand_OP_GetOrigin( entity player, array<string> args ){
	OP_ChatServerPrivateMessage( player, "Origin："+player.GetOrigin() )
	return true
}

bool function ClientCommand_TP(entity player, array<string> args) {
    int playerUID = player.GetUID().tointeger()
    if (!isOP(playerUID)) {
        OP_ChatServerPrivateMessage(player, "你没有管理员权限！！！")
        return true
    }
    if ( args.len() == 0 || args.len() != 2 ) {
        OP_ChatServerPrivateMessage(player, "====================用法====================")
        OP_ChatServerPrivateMessage(player, "TP < Name > < Name >")
        OP_ChatServerPrivateMessage(player, "===========================================")
        return true
    }
    entity player1 = GetPlayerByName(args[0])
    entity player2 = GetPlayerByName(args[1])
    if (player1 == null || player2 == null || player1 == player2 || !IsAlive(player1) || !IsAlive(player2))
        return true
    vector player2Origin = player2.GetOrigin()
    player1.SetInvulnerable()
    player2.SetInvulnerable()
    player1.SetOrigin(player2Origin)
    player1.ClearInvulnerable()
    player2.ClearInvulnerable()

    return true
}

bool function ClientCommand_Player(entity player, array<string> args) {
    if ( args.len() == 0 || args.len() != 1 ) {
        OP_ChatServerPrivateMessage(player, "====================用法====================")
        OP_ChatServerPrivateMessage(player, "Player list")
        OP_ChatServerPrivateMessage(player, "===========================================")
        return true
    }
    if (args[0] == "list") {
        foreach ( targetPlayer in GetPlayerArray() ) {
            OP_ChatServerPrivateMessage(player , "UID: " + targetPlayer.GetUID() + "  Name: " + targetPlayer.GetPlayerName())
        }
        return true
    }
    return true
}

bool function ClientCommand_GameRules_ChangeMap(entity player, array<string> args) {
    int playerUID = player.GetUID().tointeger()
    if (!isOP(playerUID)) {
        OP_ChatServerPrivateMessage(player, "你没有管理员权限！！！")
        return true
    }
    if ( args.len() == 0 || args.len() != 2) {
        OP_ChatServerPrivateMessage(player, "====================用法====================")
        OP_ChatServerPrivateMessage(player, "GameRules_ChangeMap < 地图 > < 模式 >")
        OP_ChatServerPrivateMessage(player, "===========================================")
        return true
    }
    GameRules_ChangeMap(args[0], args[1])
    return true
}

bool function ClientCommand_OPVersion(entity player, array<string> args) {
    OP_ChatServerPrivateMessage(player, "Version：" + OPVersion)
    return true
}

bool function ClientCommand_Die(entity player, array<string> args) {
    int playerUID = player.GetUID().tointeger()
    if (!isOP(playerUID)) {
        OP_ChatServerPrivateMessage(player, "你没有管理员权限！！！")
        return true
    }
    if ( args.len() == 0 || args.len() != 1) {
        OP_ChatServerPrivateMessage(player, "====================用法====================")
        OP_ChatServerPrivateMessage(player, "Die < Name >")
        OP_ChatServerPrivateMessage(player, "===========================================")
        return true
    }
    entity player1 = GetPlayerByName(args[0]) //GetPlayerByIdentifier(args[0])
    if ( player1 == null || !IsAlive(player1) )
        return true
    player1.Die()

    return true
}

bool function ClientCommand_OP(entity player, array<string> args) {
    int playerUID = player.GetUID().tointeger()
    if (!isOP(playerUID)) {
        OP_ChatServerPrivateMessage(player, "你没有管理员权限！！！")
        return true
    }

    if (args.len() == 0) {
        OP_ChatServerPrivateMessage(player, "====================用法====================")
        OP_ChatServerPrivateMessage(player, "添加管理员: OP add < UID >")
        OP_ChatServerPrivateMessage(player, "移除管理员: OP remove < UID >")
        OP_ChatServerPrivateMessage(player, "列出管理员: OP list")
        OP_ChatServerPrivateMessage(player, "===========================================")
        return true
    }

    string cmd = args[0]

    // 添加管理员
    if (cmd == "add" && args.len() >= 2) {
        string newUID = args[1]

        if (isOP(newUID.tointeger())) {
            OP_ChatServerPrivateMessage(player, "该用户已是管理员")
            return true
        }

        string currentOPs = GetConVarString("OP_UIDS")
        string updatedOPs = currentOPs == "" ? newUID : currentOPs + "," + newUID
        SetConVarString("OP_UIDS", updatedOPs)

        OP_ChatServerPrivateMessage(player, "已添加管理员: " + newUID)
        return true
    }
    // 移除管理员
    else if (cmd == "remove" && args.len() >= 2) {
        string targetUID = args[1]

        string currentOPs = GetConVarString("OP_UIDS")
        array<string> opList = split(currentOPs, ",")

        bool found = false
        array<string> newList = []
        foreach (uid in opList) {
            if (uid == targetUID) {
                found = true
                continue
            }
            if (uid != "") {
                newList.append(uid)
            }
        }

        if (!found) {
            OP_ChatServerPrivateMessage(player, "未找到该管理员")
            return true
        }

        string newOPs = join_strings(newList, ",")
        SetConVarString("OP_UIDS", newOPs)

        OP_ChatServerPrivateMessage(player, "已移除管理员: " + targetUID)
        return true
    }
    // 列出管理员
    else if (cmd == "list") {
        string opList = GetConVarString("OP_UIDS")

        if (opList == "") {
            OP_ChatServerPrivateMessage(player, "管理员列表为空")
        } else {
            OP_ChatServerPrivateMessage(player, "管理员UID: " + opList)
        }
        return true
    }

    return true
}

//bool function ClientCommand_ServerCommand(entity player, array<string> args) {
//    if (args.len() == 0){
//        OP_ChatServerPrivateMessage(player, "======================用法======================")
//        OP_ChatServerPrivateMessage(player, "ServerCommand < 命令 >")
//        OP_ChatServerPrivateMessage(player, "===============================================")
//        return true
//    }
//
//    if (!isOP(player.GetUID().tointeger())) {
//        OP_ChatServerPrivateMessage(player, "你没有管理员权限！！！")
//        return true
//    }
//
//    string command = args[0]
//    ServerCommand(command)
//    return true
//}

bool function ClientCommand_se_cheats(entity player, array<string> args) {
    if (!isOP(player.GetUID().tointeger())) {
        OP_ChatServerPrivateMessage(player, "你没有管理员权限！！！")
        return true
    }

    if ( args.len() == 0 || args.len() != 1 ) {
        OP_ChatServerPrivateMessage(player, "====================用法====================")
        OP_ChatServerPrivateMessage(player, "设置sv_cheats: se_cheats < 0 | 1 >")
        OP_ChatServerPrivateMessage(player, "===========================================")
        return true
    }

    string state = args[0]

    if (state == "1") {
        ServerCommand("sv_cheats 1")
    } else if (state == "0") {
        ServerCommand("sv_cheats 0")
    }

    return true
}