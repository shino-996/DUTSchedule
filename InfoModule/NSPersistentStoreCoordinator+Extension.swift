//
//  NSPersistentStoreCoordinator+Extension.swift
//  DUTInfomation
//
//  Created by shino on 2018/6/8.
//  Copyright © 2018 shino. All rights reserved.
//

import CoreData

extension NSPersistentStoreCoordinator {
    // 备份 Core Data sqlite 文件, 用于手表和手机之间同步
    func backupFile() -> URL {
        // 目前只有一个 alite 文件, 所以暂时硬编码
        let sourceStore = persistentStores.first!
        let backupCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let options = (sourceStore.options ?? [:]).merging([NSReadOnlyPersistentStoreOption: true]) { $1 }
        let backupStore = try! backupCoordinator.addPersistentStore(ofType: sourceStore.type,
                                                                    configurationName: sourceStore.configurationName,
                                                                    at: sourceStore.url,
                                                                    options: options)
        let backupStoreOptions: [AnyHashable: Any] = [NSReadOnlyPersistentStoreOption: true,
                                                      NSSQLitePragmasOption: ["journal_mode": "DELETE"],
                                                      NSSQLiteManualVacuumOption: true]
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")!
        let url = groupURL.appendingPathComponent("backup.data")
        try! backupCoordinator.migratePersistentStore(backupStore, to: url, options: backupStoreOptions, withType: NSSQLiteStoreType)
        return url
    }
}
