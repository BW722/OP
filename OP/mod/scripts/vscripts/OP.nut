global function OP_Init
global string OPPrefix = "\x1b[31m" + "[OP]" + "\x1b[0m"


void function OP_Init() {
    AddClientCommandCallback("se_cheats", ClientCommand_se_cheats)
    AddClientCommandCallback("ServerCommand", ClientCommand_ServerCommand)
    AddClientCommandCallback("OPVersion", ClientCommand_OPVersion)
    AddClientCommandCallback("Die", ClientCommand_Die) // kill同样的效果
    AddClientCommandCallback("OP", ClientCommand_OP)
}

void function OP_ChatServerPrivateMessage(entity player, string message) {
    Chat_ServerPrivateMessage(player, OPPrefix + "\x1b[32m" + message + "\x1b[0m", false, false)
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

bool function ClientCommand_OPVersion(entity player, array<string> args) {
    OP_ChatServerPrivateMessage(player, "Version：" + NSGetModVersionByModName("OP"))
    return true
}

bool function ClientCommand_Die(entity player, array<string> args) {
    int playerUID = player.GetUID().tointeger()
    if (!isOP(playerUID)) {
        OP_ChatServerPrivateMessage(player, "你没有管理员权限！！！")
        return true
    }
    player.Die()
    return true
}

bool function ClientCommand_OP(entity player, array<string> args) {
    if (args.len() == 0) {
        OP_ChatServerPrivateMessage(player, "======================用法======================")
        OP_ChatServerPrivateMessage(player, "添加管理员: OP add < UID >")
        OP_ChatServerPrivateMessage(player, "移除管理员: OP remove < UID >")
        OP_ChatServerPrivateMessage(player, "列出管理员: OP list")
        OP_ChatServerPrivateMessage(player, "===============================================")
        return true
    }

    int playerUID = player.GetUID().tointeger()
    if (!isOP(playerUID)) {
        OP_ChatServerPrivateMessage(player, "你没有管理员权限！！！")
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

bool function ClientCommand_ServerCommand(entity player, array<string> args) {
    if (args.len() == 0){
        OP_ChatServerPrivateMessage(player, "======================用法======================")
        OP_ChatServerPrivateMessage(player, "ServerCommand < command >")
        OP_ChatServerPrivateMessage(player, "===============================================")
        return true
    }

    if (!isOP(player.GetUID().tointeger())) {
        OP_ChatServerPrivateMessage(player, "你没有管理员权限！！！")
        return true
    }

    string command = args[0]
    ServerCommand(command)
    return true
}

bool function ClientCommand_se_cheats(entity player, array<string> args) {
    if (args.len() == 0) {
        OP_ChatServerPrivateMessage(player, "======================用法======================")
        OP_ChatServerPrivateMessage(player, "设置sv_cheats: se_cheats < 0 | 1 >")
        OP_ChatServerPrivateMessage(player, "===============================================")
        return true
    }

    if (!isOP(player.GetUID().tointeger())) {
        OP_ChatServerPrivateMessage(player, "你没有管理员权限！！！")
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