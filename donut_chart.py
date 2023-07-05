import plotly.express as px
import pandas as pd

data = {
    'CLICK_TYPE': ['Organic click', 'Keyword change', 'Stayed in search engine', 'Ad click'],
    'CLICK_COUNT': [10948661, 6705693, 28816409, 2969]
}
df = pd.DataFrame(data)

# Calculate the percentage of each click type
df['PERCENTAGE'] = df['CLICK_COUNT'] / df['CLICK_COUNT'].sum() * 100

# Create the donut chart with annotations
fig = px.pie(df, values='CLICK_COUNT', names='CLICK_TYPE', hole=0.4,
             labels={'CLICK_COUNT': 'Clicks', 'CLICK_TYPE': 'Click Type'},
             title='Top 10 Search Engines CTR Analysis',
             color_discrete_sequence=['#5B5F97', '#FFC145', '#FF6B6C', '#C6E2FF'],
             width=800, height=500)
fig.update_traces(textinfo='percent+value+label', textposition='outside')
fig.update_layout(
    font=dict(
        size=18,
    ),
    font_family='system-ui'
)
fig.show()
