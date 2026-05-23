#!/bin/bash
# === Emby API Curl 模拟测试命令 ===
# 使用前请替换以下变量，然后执行: bash docs/api_test_curl.sh

SERVER_URL="http://your-emby-server:8096"
API_KEY="your-api-key"
USER_ID="your-user-id"
PARENT_ID="your-library-id"
ITEM_ID="your-item-id"
MEDIA_SOURCE_ID="your-media-source-id"
STUDIO_ID="your-studio-id"
PERSON_ID="your-person-id"

echo "========================================"
echo "Emby API 模拟测试"
echo "Server: $SERVER_URL"
echo "========================================"

# --- 1. 媒体库筛选：按 Genre ---
echo ""
echo "=== 1. 按 Genre 筛选 ==="
curl -s -X GET "$SERVER_URL/Users/$USER_ID/Items?ParentId=$PARENT_ID&IncludeItemTypes=Movie,Series&Recursive=true&Genres=科幻&Limit=20&Fields=PrimaryImageAspectRatio,BasicSyncInfo,ProductionYear&api_key=$API_KEY" \
  -H "Content-Type: application/json" | jq '.Items[] | {name: .Name, year: .ProductionYear, genres: .Genres}'

# --- 2. 媒体库筛选：按 StudioIds ---
echo ""
echo "=== 2. 按 Studio ID 筛选 ==="
curl -s -X GET "$SERVER_URL/Users/$USER_ID/Items?ParentId=$PARENT_ID&IncludeItemTypes=Movie,Series&Recursive=true&StudioIds=$STUDIO_ID&Limit=20&Fields=PrimaryImageAspectRatio,BasicSyncInfo,ProductionYear&api_key=$API_KEY" \
  -H "Content-Type: application/json" | jq '.Items[] | {name: .Name, studios: .Studios}'

# --- 3. 媒体库筛选：Genre + Studio 组合 ---
echo ""
echo "=== 3. Genre + Studio 组合筛选 ==="
curl -s -X GET "$SERVER_URL/Users/$USER_ID/Items?ParentId=$PARENT_ID&IncludeItemTypes=Movie,Series&Recursive=true&Genres=动作&StudioIds=$STUDIO_ID&Limit=20&api_key=$API_KEY" \
  -H "Content-Type: application/json" | jq '.TotalRecordCount, .Items[] | .Name'

# --- 4. 播放开始 (Start) ---
echo ""
echo "=== 4. 播放开始 ==="
curl -s -X POST "$SERVER_URL/Users/$USER_ID/PlayingItems/$ITEM_ID?MediaSourceId=$MEDIA_SOURCE_ID&CanSeek=true&PlayMethod=DirectStream&api_key=$API_KEY" \
  -H "Content-Type: application/json" \
  -w "\nHTTP Status: %{http_code}\n"

# --- 5. 播放进度 (Progress) ---
echo ""
echo "=== 5. 播放进度 ==="
curl -s -X POST "$SERVER_URL/Users/$USER_ID/PlayingItems/$ITEM_ID/Progress?MediaSourceId=$MEDIA_SOURCE_ID&PositionTicks=600000000&IsPaused=false&PlayMethod=DirectStream&api_key=$API_KEY" \
  -H "Content-Type: application/json" \
  -w "\nHTTP Status: %{http_code}\n"

# --- 6. 播放停止 (Stopped) ---
echo ""
echo "=== 6. 播放停止 ==="
curl -s -X POST "$SERVER_URL/Sessions/Playing/Stopped?api_key=$API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"ItemId\": \"$ITEM_ID\",
    \"MediaSourceId\": \"$MEDIA_SOURCE_ID\",
    \"PositionTicks\": 600000000
  }" \
  -w "\nHTTP Status: %{http_code}\n"

# --- 7. 获取关联作品 (Studio) ---
echo ""
echo "=== 7. Studio 关联作品 ==="
curl -s -X GET "$SERVER_URL/Users/$USER_ID/Items?IncludeItemTypes=Movie,Series&Recursive=true&StudioIds=$STUDIO_ID&SortBy=ProductionYear&SortOrder=Descending&Limit=100&Fields=PrimaryImageAspectRatio,BasicSyncInfo,ProductionYear&api_key=$API_KEY" \
  -H "Content-Type: application/json" | jq '.Items[] | {name: .Name, year: .ProductionYear}'

# --- 8. 获取关联作品 (Person) ---
echo ""
echo "=== 8. Person 关联作品 ==="
curl -s -X GET "$SERVER_URL/Users/$USER_ID/Items?IncludeItemTypes=Movie,Series&Recursive=true&PersonIds=$PERSON_ID&SortBy=ProductionYear&SortOrder=Descending&Limit=100&Fields=PrimaryImageAspectRatio,BasicSyncInfo,ProductionYear&api_key=$API_KEY" \
  -H "Content-Type: application/json" | jq '.Items[] | {name: .Name, year: .ProductionYear}'

echo ""
echo "========================================"
echo "测试完成"
echo "========================================"
