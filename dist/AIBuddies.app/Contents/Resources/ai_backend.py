#!/usr/bin/env python3
"""
AIBuddies Backend - OpenAI API Integration
Simple backend to handle chat messages and OpenAI API calls using urllib (no external dependencies)
"""

import json
import sys
import os
import urllib.request
import urllib.parse
import urllib.error

class AIBuddiesBackend:
    def __init__(self, api_key=None):
        self.api_key = api_key or os.getenv('OPENAI_API_KEY')
        if not self.api_key:
            raise ValueError("OpenAI API key not provided")
        
        self.conversation_history = []
    
    def send_message(self, message):
        try:
            self.conversation_history.append({
                "role": "user", 
                "content": message
            })
            
            # Prepare the request data
            messages = [
                {"role": "system", "content": "You are Leo Pet, a helpful AI assistant buddy. Be friendly, concise, and helpful."},
                *self.conversation_history
            ]
            
            data = {
                "model": "gpt-3.5-turbo",
                "messages": messages,
                "max_tokens": 150,
                "temperature": 0.7
            }
            
            # Make the API request
            req = urllib.request.Request(
                "https://api.openai.com/v1/chat/completions",
                data=json.dumps(data).encode('utf-8'),
                headers={
                    "Content-Type": "application/json",
                    "Authorization": f"Bearer {self.api_key}"
                }
            )
            
            with urllib.request.urlopen(req) as response:
                result = json.loads(response.read().decode('utf-8'))
            
            ai_response = result['choices'][0]['message']['content']
            
            self.conversation_history.append({
                "role": "assistant",
                "content": ai_response
            })
            
            return {
                "success": True,
                "response": ai_response,
                "error": None
            }
            
        except urllib.error.HTTPError as e:
            error_body = e.read().decode('utf-8')
            try:
                error_json = json.loads(error_body)
                error_msg = error_json.get('error', {}).get('message', f'HTTP {e.code}')
            except:
                error_msg = f'HTTP {e.code}: {error_body}'
            return {
                "success": False,
                "response": None,
                "error": f"API Error: {error_msg}"
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
        result = {"success": False, "error": "Usage: python ai_backend.py <api_key> <message>"}
        print(json.dumps(result))
        sys.exit(1)
    
    api_key = sys.argv[1]
    message = sys.argv[2]
    
    try:
        backend = AIBuddiesBackend(api_key)
        result = backend.send_message(message)
        print(json.dumps(result))
    except Exception as e:
        result = {"success": False, "error": str(e)}
        print(json.dumps(result))

if __name__ == "__main__":
    main()