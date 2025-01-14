//
//  CricketScoresWidgetLiveActivity.swift
//  CricketScoresWidget
//
//  Created by Mani Kanchi on 10/11/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CricketScoresWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CricketScoresWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CricketScoresWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension CricketScoresWidgetAttributes {
    fileprivate static var preview: CricketScoresWidgetAttributes {
        CricketScoresWidgetAttributes(name: "World")
    }
}

extension CricketScoresWidgetAttributes.ContentState {
    fileprivate static var smiley: CricketScoresWidgetAttributes.ContentState {
        CricketScoresWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: CricketScoresWidgetAttributes.ContentState {
         CricketScoresWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: CricketScoresWidgetAttributes.preview) {
   CricketScoresWidgetLiveActivity()
} contentStates: {
    CricketScoresWidgetAttributes.ContentState.smiley
    CricketScoresWidgetAttributes.ContentState.starEyes
}
