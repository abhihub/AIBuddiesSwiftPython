#!/usr/bin/env python3
"""
AIBuddies Backend - OpenAI API Integration
Simple backend to handle chat messages and OpenAI API calls
"""

import json
import sys
import os
from openai import OpenAI

class AIBuddiesBackend:
    def __init__(self, api_key=None):
        self.api_key = api_key or os.getenv('OPENAI_API_KEY')
        if not self.api_key:
            raise ValueError("OpenAI API key not provided")
        
        self.client = OpenAI(api_key=self.api_key)
        self.conversation_history = []
    
    def send_message(self, message):
        try:
            self.conversation_history.append({
                "role": "user", 
                "content": message
            })
            
            response = self.client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are Leo Pet, a helpful AI assistant buddy. Be friendly, concise, and helpful."},
                    *self.conversation_history
                ],
                max_tokens=150,
                temperature=0.7
            )
            
            ai_response = response.choices[0].message.content
            
            self.conversation_history.append({
                "role": "assistant",
                "content": ai_response
            })
            
            return {
                "success": True,
                "response": ai_response,
                "error": None
            }
            
        except Exception as e:
            return {
                "success": False,
                "response": None,
                "error": str(e)
            }
    
    def get_conversation_history(self):
        return self.conversation_history
    
    def clear_conversation(self):
        self.conversation_history = []

def main():
    if len(sys.argv) < 3:
        print(json.dumps({"success": False, "error": "Usage: python ai_backend.py <api_key> <message>"}))
        sys.exit(1)
    
    api_key = sys.argv[1]
    message = sys.argv[2]
    
    try:
        backend = AIBuddiesBackend(api_key)
        result = backend.send_message(message)
        print(json.dumps(result))
    except Exception as e:
        print(json.dumps({"success": False, "error": str(e)}))

if __name__ == "__main__":
    main()