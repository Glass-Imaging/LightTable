// Copyright (c) 2022 Glass Imaging Inc.
// Author: Fabio Riccardi <fabio@glass-imaging.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

struct RecursiveView<Item, ID, SelectionValue, RowContent>: View where Item: Identifiable, ID : Hashable, SelectionValue: Hashable, RowContent: View {
    let item:Item
    let id:KeyPath<Item, ID>
    let children:KeyPath<Item, [Item]?>
    var selection:Binding<Set<SelectionValue>>?
    let rowContent:(Item) -> RowContent

    @State var expanded = false

    var body: some View {
        if let subChildren = item[keyPath: children] {
            DisclosureGroup(isExpanded: $expanded, content: {
                if expanded {
                    ForEach(subChildren, id: id) { item in
                        RecursiveView(item: item, id: id, children: children, selection: selection, rowContent: rowContent)
                    }
                }
            }, label: {
                rowContent(item)
            })
        } else {
            rowContent(item)
        }
    }
}