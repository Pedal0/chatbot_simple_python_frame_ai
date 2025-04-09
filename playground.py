from agno.agent import Agent
from agno.models.ollama import Ollama
from agno.models.openai import OpenAIChat
from agno.tools.sql import SQLTools
from sqlalchemy import create_engine
from agno.tools.duckduckgo import DuckDuckGoTools
from agno.tools.giphy import GiphyTools
from agno.playground import Playground, serve_playground_app
from agno.tools.calculator import CalculatorTools
from shell_toolkit import ShellTools
from agno.tools.python import PythonTools


db_url = "postgresql://ai:ai@localhost:5532/ai"
engine = create_engine(db_url)

cmd_agent = Agent(
    name="Cmd Agent",
    tools=[
        ShellTools()
        ],
    instructions="You are equipped with tools to run cmd commands on windows.",
    show_tool_calls=True, 
    markdown=True)

agent_calculator = Agent(
    name="Calculator Agent",
    model=Ollama(id="qwq:latest"),
    tools=[
        CalculatorTools(
            add=True,
            subtract=True,
            multiply=True,
            divide=True,
            exponentiate=True,
            factorial=True,
            is_prime=True,
            square_root=True,
        )
    ],
    instructions="You are equipped with tools to perform calculations.",
    show_tool_calls=True,
    markdown=True,
)

agent_sql = Agent(
    name="SQL Agent",
    model=Ollama(id="qwq:latest"),
    tools=[SQLTools(db_engine=engine)],
    instructions="You are equipped with tools to manage my SQL database",
    markdown=True,
    show_tool_calls=True,
    retries=3,
)
web_searcher = Agent(
    name="Web Searcher",
    model=Ollama(id="qwq:latest"),
    role="Searches the web for information on a topic in relation with the user question",
    tools=[DuckDuckGoTools()],
    add_datetime_to_instructions=True,
    add_history_to_messages=True,
    retries=3,
)
gif_agent = Agent(
    name="Gif Generator Agent",
    model=OpenAIChat(id="gpt-4o-mini"),
    tools=[GiphyTools(limit=1)],
    description="You are an AI agent that can generate gifs using Giphy.",
    instructions=[
        "Come up with a funny Giphy query and use the `search_gifs` tool to find the appropriate gif to illustrate the response.",
    ],
    debug_mode=False,
    show_tool_calls=True,
)

graph_agent = Agent(
    name="Graph Generator Agent",
    model=Ollama(id="qwq:latest"),
    tools=[PythonTools(
        base_dir="graphs",
        save_and_run=True,
        pip_install=True,
        run_code=True
    )],
    description="You are an AI agent that can create data visualizations using Python.",
    instructions=[
        "Create visualizations based on data provided by other agents or user requests.",
        "First, analyze the data structure provided and determine the most appropriate visualization type.",
        "For tabular data, consider using pandas to process and clean the data before visualization.",
        "For time-series data, use line charts or area charts and ensure proper date formatting.",
        "For categorical comparisons, use bar charts, pie charts, or bubble charts.",
        "For relational data, consider scatter plots or heatmaps.",
        "Use matplotlib, seaborn, or plotly depending on complexity (prefer plotly for interactive visualizations).",
        "When creating visualizations:",
        "  - Add descriptive titles, labels, and legends",
        "  - Use appropriate color schemes (colorblind-friendly when possible)",
        "  - Include data source in annotations when relevant",
        "  - Add grid lines for better readability when appropriate",
        "  - Adjust font sizes and styles for clarity",
        "Save generated visualizations to the 'graphs' directory with descriptive filenames.",
        "Return the path to the generated image file in your response along with a brief interpretation of the visualization.",
        "If raw data needs processing, explain the transformations you're applying.",
        "If you need to install any visualization libraries, use the pip_install_package function.",
        "For interactive visualizations, create HTML files with plotly that can be shared."
    ],
    show_tool_calls=True,
    markdown=True,
    retries=3,
    add_history_to_messages=True,
)

summarize_agent = Agent(
    name="Summarize Agent",
    model=Ollama(id="qwq:latest"),
    instructions=[
        "Summarize the findings other agents have provided.",
        "Provide a thoughtful and engaging summary.",
    ],
    show_tool_calls=True,
    add_history_to_messages=True,
    markdown=True,
)

search_team = Agent(
    name="Search Team",
    model=Ollama(id="qwq:latest"),
    team=[agent_sql, web_searcher],
    instructions=[
        "You are specialized in finding information from different sources.",
        "First, ask the SQL agent to search for data in the database.",
        "If the SQL agent finds data, summarize the findings, otherwise state that no data was found.",
        "If the SQL agent finds data that could be visualized, format it in a way that can be used by the Graph Generator Agent.",
        "If the SQL agent doesn't find any data, ask the web searcher to find information on the topic.",
        "If the web searcher finds information, summarize the findings, otherwise state that no information was found.",
        "When finding numerical data from any source, present it in a structured format (like tables or lists) that can be easily processed for visualization.",
    ],
    show_tool_calls=True,
    add_history_to_messages=True,
    markdown=True,
)

data_viz_team = Agent(
    name="Data Visualization Team",
    model=Ollama(id="qwq:latest"),
    team=[search_team, graph_agent, summarize_agent],
    instructions=[
        "You are specialized in creating data visualizations based on user requests.",
        "First, use the Search Team to find relevant numerical or tabular data.",
        "Once data is found, use the Graph Generator Agent to create appropriate visualizations.",
        "Provide a clear interpretation of the visualization using the Summarize Agent.",
        "Focus on delivering insights through visual representations of data."
    ],
    show_tool_calls=True,
    add_history_to_messages=True,
    markdown=True,
)

calculation_team = Agent(
    name="Calculation Team",
    model=Ollama(id="qwq:latest"),
    team=[agent_calculator, summarize_agent],
    instructions=[
        "You are specialized in performing mathematical calculations and analyses.",
        "Use the Calculator Agent to perform any necessary calculations.",
        "Provide clear explanations of the calculations performed and results obtained.",
        "Use the Summarize Agent to present findings in an understandable way."
    ],
    show_tool_calls=True,
    add_history_to_messages=True,
    markdown=True,
)

system_team = Agent(
    name="System Operations Team",
    model=Ollama(id="qwq:latest"),
    team=[cmd_agent, summarize_agent],
    instructions=[
        "You are specialized in performing system operations and commands.",
        "Use the CMD Agent to execute appropriate system commands based on user requests.",
        "Provide clear explanations of what commands were run and what they accomplished.",
        "Use the Summarize Agent to present the results in an understandable way.",
        "Focus on system-related tasks and retrieving system information."
    ],
    show_tool_calls=True,
    add_history_to_messages=True,
    markdown=True,
)

entertainment_team = Agent(
    name="Entertainment Team",
    model=Ollama(id="qwq:latest"),
    team=[gif_agent, summarize_agent],
    instructions=[
        "You are specialized in providing entertaining content.",
        "Use the Gif Agent to find appropriate gifs related to the user's request.",
        "Create engaging and fun responses that incorporate visual elements.",
        "Focus on making interactions enjoyable and light-hearted."
    ],
    show_tool_calls=True,
    add_history_to_messages=True,
    markdown=True,
)

full_team = Agent(
    name="Full Agent Team",
    model=Ollama(id="qwq:latest"),
    team=[search_team, gif_agent, agent_calculator, cmd_agent, summarize_agent, graph_agent],
    description="Complete team with all available agents",
    instructions=[
        "You have access to all available agents and can use them as needed to fulfill the user's request.",
        "Coordinate between the different agents to provide the most comprehensive response possible.",
        "If the request involves multiple domains, break it down and assign appropriate agents to each part."
    ],
    show_tool_calls=True,
    add_history_to_messages=True,
    markdown=True,
)

coordinator_agent = Agent(
    name="AlBot - Coordinator Agent",
    model=Ollama(id="qwq:latest"),
    team=[search_team, data_viz_team, calculation_team, system_team, entertainment_team, full_team],
    description="I am AlBot, your AI assistant coordinator",
    instructions=[
        "You are the main coordinator who determines which specialized team is best suited to handle the user's request.",
        "Analyze the user request carefully to determine its primary purpose and required capabilities.",
        "Select the appropriate specialized team based on the following criteria:",
        "  - For information retrieval requests: use the Search Team",
        "  - For data visualization requests: use the Data Visualization Team",
        "  - For mathematical calculation requests: use the Calculation Team",
        "  - For system operation requests: use the System Operations Team",
        "  - For entertainment or light-hearted requests: use the Entertainment Team",
        "If the request spans multiple domains or doesn't clearly fit into any specialized team, use the Full Team.",
        "Before passing the request to a team, clearly explain why you've chosen this particular team.",
        "Always aim to provide comprehensive, accurate, and helpful responses.",
        "If a team's response is insufficient, you may engage another team or switch to the Full Team.",
    ],
    show_tool_calls=True,
    add_history_to_messages=True,
    markdown=True,
)

app = Playground(agents=[coordinator_agent]).get_app()

if __name__ == "__main__":
    serve_playground_app("playground:app", reload=True)