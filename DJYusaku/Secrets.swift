//
//  Secrets.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2019/10/12.
//  Copyright © 2019 Yusaku. All rights reserved.
//

/*
  デベロッパートークンなどの秘匿値の情報はSecrets構造体に保存しますが、
  実際の値はGitにignoreされるファイルである Secrets+Local.swift を作成して、
  次のようにSecretsのextensionとして値を記述してください。
 
     // Secrets+Local.swift
     extension Secrets {
         static let DeveloperToken = "..."
         // その他秘匿にしたい値...
     }

 */

struct Secrets {
    /* 変更禁止 : この中に秘匿値を記述してはいけません */
}
