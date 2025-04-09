from agno.agent import Agent, AgentMemory
from agno.models.ollama import Ollama
from agno.playground import Playground, serve_playground_app
from agno.storage.sqlite import SqliteStorage
from agno.memory.db.sqlite import SqliteMemoryDb

agent = Agent(
    name="Theo",
    model=Ollama(id="llama3.1:8b"),
    instructions="IMPORTANT Respond in the language of the user usually french.",
    description="Je suis un assistant virtuel nommé Theo, conçu pour aider les utilisateurs en français.",
    read_chat_history=True,
    add_history_to_messages=True,
    num_history_responses=5,
    markdown=True,
    storage=SqliteStorage(table_name="theo_agent", db_file="tmp/agent_storage.db"),
    memory=AgentMemory(
        db=SqliteMemoryDb(table_name="agent_memory", db_file="tmp/agent_memory.db"),
        create_user_memories=True,
        update_user_memories_after_run=True,
        create_session_summary=True,
        update_session_summary_after_run=True,
    ),
)

app = Playground(agents=[agent]).get_app()

if __name__ == "__main__":
    serve_playground_app("playground:app", reload=True)