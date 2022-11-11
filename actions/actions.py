from typing import Any, Text, Dict, List

from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
import requests
import json
import re


class ActionLookUpWordDictionary(Action):
    def name(self) -> Text:
        return 'action_lookUp_en'

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,  domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        word = str(tracker.get_slot('enword')).lower()
        print(word)
        if not word:
            dispatcher.utter_message(
                "Đôi lúc sự thông thái của tôi cũng có giới hạn!")
            return []
        url = 'https://api.tracau.vn/WBBcwnwQpV89/s/{}/en'.format(word)
        response = requests.get(url).text
        json_data = json.loads(response)['tratu'][0]['fields']['fulltext']
        try:
            pro = re.search(
                r"<\s*tr\s+id\s*=\s*\"pa\"[^>]*>.+?<\s*\/\s*tr>", json_data).group()
            tl = re.search(
                r"<\s*tr\s+id\s*=\s*\"tl\"[^>]*>.+?<\s*\/\s*tr>", json_data).group()
        except e1:
            print(e1)

        try:
            meanings = re.findall(
                r"<\s*tr\s+id\s*=\s*\"mn\"[^>]*>.+?<\s*\/\s*tr>", json_data)
        except Exception:
            dispatcher.utter_message(
                "Đôi lúc sự thông thái của tôi cũng có giới hạn!")
            return []

        pro = re.sub(r"<\s*[^>]+>", "", pro)
        tl = re.sub(r"<\s*[^>]+>", "", tl)
        for i in range(len(meanings)):
            meanings[i] = re.sub(r"<\s*[^>]+>", "", meanings[i])
        text_respond = "=> " + word.title()
        if pro is not None:
            text_respond += pro.replace("◘", " ")
        if tl is not None:
            text_respond += "\n" + tl.replace("*", "* ")
        if meanings:
            for mean in meanings:
                if mean is not None:
                    text_respond += "\n" + mean.replace("■", "  -  ")

            dispatcher.utter_message(
                "Bằng sự thông thái của tôi, đây là thứ bạn cần tìm:\n" + text_respond)
        else:
            dispatcher.utter_message(
                "Đôi lúc sự thông thái của tôi cũng có giới hạn!")
            return []

        return []
