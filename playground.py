from agno.agent import Agent, AgentMemory
from agno.models.ollama import Ollama
from agno.playground import Playground, serve_playground_app
from agno.storage.sqlite import SqliteStorage
from agno.memory.db.sqlite import SqliteMemoryDb

agent = Agent(
    name="Agent",
    model=Ollama(id="llama3.1:8b"),
    instructions="IMPORTANT Respond in the language of the user usually french. Juste pour contexte tu peux utiliser ton outil de mémoire pour te souvenir de ce que l'utilisateur a dit dans le passé, si tu l'utilise pense bien a mettre en forme la reponse dans un langage naturel. Si jamais il n'y a rien d'interressant dans la mémoire parle lui simplement avec tes connaissances générales.",
    description="Je suis un assistant virtuel nommé Agent, conçu pour aider les utilisateurs en français.",
    read_chat_history=True,
    add_history_to_messages=True,
    num_history_responses=5,
    markdown=True,
    storage=SqliteStorage(table_name="agent_agent", db_file="tmp/agent_storage.db"),
)

app = Playground(agents=[agent]).get_app()

if __name__ == "__main__":
    serve_playground_app("playground:app", reload=True)