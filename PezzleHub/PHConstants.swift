//
//  BasicStructures.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

struct TermsAndConditionsChapter {
    var title = "プライバシーポリシー"
    var subchapters = [TermsAndConditionsSubChapter(), TermsAndConditionsSubChapter(), TermsAndConditionsSubChapter(), TermsAndConditionsSubChapter(), TermsAndConditionsSubChapter()]
}

struct TermsAndConditionsSubChapter {
    var title = "1. 当社のサービスのご利用"
    var description = "基本ガイドラインは当社のサービス（当社が提供するサービスとソフトウエアの媒体）をご利用になるすべての方に共通して適用されます。"
}

//
let defaultAnimationDuration = 0.3

let perzzleAPIDomain = "http://api.perzzle.com/v1"

let perzzleCourseURLPattern = "http://perzzle.com/courses/(\\d+)/??"
let perzzleAppIdentifier = "com.perzzle.PerzzleHub"
let perzzleStudioPath = "http://studio.perzzle.com/dashboard"

let perzzleAppStoreURL = "https://itunes.apple.com/jp/app/perzzle/id1125885855?ls=1&mt=8"
let perzzleStudioAppStoreURL = "https://itunes.apple.com/jp/app/perzzlestudio/id1125885880?ls=1&mt=8"

let perzzleServiceName = "perzzle"

enum PHNotificationType: String {
    
    case NextChapterDelivery = "next_chapter_delivery"
    
    static let notificationTypeKey = "notification_type"
}
