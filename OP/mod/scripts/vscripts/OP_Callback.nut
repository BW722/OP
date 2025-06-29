global function GetPlayerByUID
global function GetPlayerByName
//global function GetPlayerByIdentifier

//entity function GetPlayerByIdentifier(string identifier) {
//    int inputType = IdentifyInputType(identifier)
//
//    switch(inputType) {
//        case 1: // UID类型
//            return GetPlayerByUID(identifier.tointeger())
//        case 2: // Name类型
//            return GetPlayerByName(identifier)
//    }
//    return null
//}
//
//int function IdentifyInputType(string input) {
//    if(input == "")
//        return 0
//
//    for(int i = 0; i < input.len(); i++) {
//        var charCode = input[i]  // 获取字符的ASCII码
//
//        if (charCode < '0' || charCode > '9') {
//            return 2  // 发现非数字字符，视为名称
//        }
//    }
//    return 1  // 全部字符都是数字，视为UID
//}

entity function GetPlayerByUID(int UID) {
    foreach ( player in GetPlayerArray() ) {
        if (player.GetUID().tointeger() == UID) {
            return player
        }
    }
    return null
}

entity function GetPlayerByName(string playerName) {
    string lowerName = playerName.tolower()
    foreach ( player in GetPlayerArray() ) {
        if (player.GetPlayerName().tostring().tolower() == lowerName) {
            return player
        }
    }
    return null
}