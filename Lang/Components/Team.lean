import VersoBlog

import Lang.Components.Feature

open Verso Genre Blog
open Verso Doc Elab ArgParse
open Lean
open Verso Output Html
open Template

namespace Lang
namespace Components

structure Member where
  url : String
  name : String
  role : Option String := none
  area : Option String := none
  link : Option String := none

/-- Render a member card. The `area` paragraph is only shown when `showArea` is set. -/
def team (member : Member) (showArea : Bool := false) : HtmlM Page Html := do
  saveCss (include_str "../../static/css/team.css")
  let webLink :=
    if let some link := member.link then {{
      <a href={{link}} title=s!"{member.name}'s website" class="member-link">{{ Icon.link (fill := "var(--color-text)") (width := "18") }}</a>
    }} else ""
  let role :=
    if let some role := member.role then {{ <p class="member-role">{{role}}</p> }} else ""
  let area :=
    if let (true, some area) := (showArea, member.area) then {{
      <p class="member-role">{{area}}</p>
    }} else ""
  return {{
    <div class="team-card" onclick="toggleCard(this)">
        <div class="image-container">
            <img src={{member.url}}/>
        </div>
        <div class="content-area">
            <div class="member-details">
                <div class="member-name"><span>{{member.name}}</span>{{webLink}}</div>
                {{role}}
                {{area}}
            </div>
        </div>
    </div>
  }}
