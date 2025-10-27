color
```cpp
// 原版
class Solution {
public:
    vector<int> shortestDistanceColor(vector<int>& colors, vector<vector<int>>& queries) {
        int n = colors.size();
        int right[n + 1][3];
        const int inf = 1 << 30;
        fill(right[n], right[n] + 3, inf);
        for (int i = n - 1; i >= 0; --i) {
            for (int j = 0; j < 3; ++j) {
                right[i][j] = right[i + 1][j];
            }
            right[i][colors[i] - 1] = i;
        }
        int left[n + 1][3];
        fill(left[0], left[0] + 3, -inf);
        for (int i = 1; i <= n; ++i) {
            for (int j = 0; j < 3; ++j) {
                left[i][j] = left[i - 1][j];
            }
            left[i][colors[i - 1] - 1] = i - 1;
        }
        vector<int> ans;
        for (auto& q : queries) {
            int i = q[0], c = q[1] - 1;
            int d = min(i - left[i + 1][c], right[i][c] - i);
            ans.push_back(d > n ? -1 : d);
        }
        return ans;
    }
};



//改写
class Solution {
 public:
  vector%3Cint%3E shortestDistance(vector<int>& colors, vector<pair<int, int>>& queries) {
    // Step 1: Record the indices of each color
    unordered_map<int, vector<int>> colorIndices;
    for (int i = 0; i < colors.size(); ++i) {
      colorIndices[colors[i]].push_back(i);
    }

    // Step 2: Process each query
    vector<int> result;
    for (const auto& query : queries) {
      int i = query.first;
      int c = query.second;

      if (colorIndices.find(c) == colorIndices.end()) {
        result.push_back(-1);
        continue;
      }

      const vector<int>& indices = colorIndices[c];
      auto pos = lower_bound(indices.begin(), indices.end(), i);

      // Check the closest index on the left and right
      int leftDistance = (pos == indices.begin()) ? INT_MAX : i - *(pos - 1);
      int rightDistance = (pos == indices.end()) ? INT_MAX : *pos - i;

      // Find the minimum distance
      int minDistance = min(leftDistance, rightDistance);
      result.push_back(minDistance);
    }

    return result;
  }


  int maxLandPlots(const std::vector<int>& gain, int target) {
    int n = gain.size();
    std::vector<std::vector<int>> dp(n, std::vector<int>(n, 0));
    int max_plots = 0;

    // 初始化 dp 数组
    for (int i = 0; i < n; ++i) {
      dp[i][i] = gain[i];
      if (dp[i][i] == target) {
        max_plots = 1;
      }
    }

    // 填充 dp 数组
    for (int len = 2; len <= n; ++len) {
      for (int i = 0; i <= n - len; ++i) {
        int j = i + len - 1;
        dp[i][j] = dp[i][j - 1] + gain[j];
        if (dp[i][j] == target) {
          max_plots = std::max(max_plots, len);
        }
      }
    }

    return max_plots;
  }
};
```

## 绿洲 并查集
```cpp
class Solution {
 public:
  int find(vector%3Cint%3E& parent, int x) {
    if (parent[x] != x) {
      parent[x] = find(parent, parent[x]);
    }
    return parent[x];
  }

  void unionSet(vector<int>& parent, int x, int y) {
    parent[find(parent, x)] = find(parent, y);
  }

  int minArea(vector<vector<char>>& grid, int x, int y) {
    int m = grid.size(), n = grid[0].size();
    vector<int> parent(m * n);
    for (int i = 0; i < m * n; ++i) {
      parent[i] = i;
    }

    int dx[] = {-1, 1, 0, 0}, dy[] = {0, 0, -1, 1};
    for (int i = 0; i < m; ++i) {
      for (int j = 0; j < n; ++j) {
        if (grid[i][j] == '1') {
          int index = i * n + j;
          for (int k = 0; k < 4; ++k) {
            int nx = i + dx[k], ny = j + dy[k];
            if (nx >= 0 && nx < m && ny >= 0 && ny < n && grid[nx][ny] == '1') {
              unionSet(parent, index, nx * n + ny);
            }
          }
        }
      }
    }

    // 找到根节点对应的最小和最大行、列坐标
    int root = find(parent, x * n + y);
    int up = m, down = 0, left = n, right = 0;
    for (int i = 0; i < m; ++i) {
      for (int j = 0; j < n; ++j) {
        if (find(parent, i * n + j) == root) {
          up = min(up, i);
          down = max(down, i);
          left = min(left, j);
          right = max(right, j);
        }
      }
    }

    return (down - up + 1) * (right - left + 1);
  }
};

class Solution {  
 public:  
  int minArea(vector<vector<char>>& grid, int x, int y) {  
    int m = grid.size(), n = grid[0].size();  
    int up = m, down = 0, left = n, right = 0;  
  
    function<void(int, int)> dfs = [&](int i, int j) {  
      if (i < 0 || i >= m || j < 0 || j >= n || grid[i][j] != '1') return;  
      grid[i][j] = '#'; // 标记为已访问  
      up = min(up, i);  
      down = max(down, i);  
      left = min(left, j);  
      right = max(right, j);  
      dfs(i - 1, j);  
      dfs(i + 1, j);  
      dfs(i, j - 1);  
      dfs(i, j + 1);  
    };  
    dfs(x, y);  
    return (down - up + 1) * (right - left + 1);  
  }  
  int minArea(vector<vector<char>>& area, int x, int y) {  
    int n = area.size();  
    int m = area[0].size();  
    int minX = x, maxX = x, minY = y, maxY = y;  
  
    // Directions for moving in the 4 possible ways (up, down, left, right)  
    vector<pair<int, int>> directions = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}};  
  
    // BFS to explore all connected '1's  
    queue<pair<int, int>> q;  
    q.push({x, y});  
    area[x][y] = 'e'; // Mark as visited by changing '1' to 'e'  
  
    while (!q.empty()) {  
      auto [cx, cy] = q.front();  
      q.pop();  
  
      for (auto& dir : directions) {  
        int nx = cx + dir.first;  
        int ny = cy + dir.second;  
  
        if (nx >= 0 && nx < n && ny >= 0 && ny < m && area[nx][ny] == '1') {  
          area[nx][ny] = 'e'; // Mark as visited  
          q.push({nx, ny});  
          minX = min(minX, nx);  
          maxX = max(maxX, nx);  
          minY = min(minY, ny);  
          maxY = max(maxY, ny);  
        }      }    }  
    // Calculate the area of the rectangle  
    return (maxX - minX + 1) * (maxY - minY + 1);  
  }};
```


## 背包
```cpp
class Solution {
public:
    double maxPrice(vector<vector<int>>& items, int capacity) {
        sort(items.begin(), items.end(), [&](const auto& a, const auto& b) { return a[1] * b[0] < a[0] * b[1]; });
        double ans = 0;
        for (auto& e : items) {
            int p = e[0], w = e[1];
            int v = min(w, capacity);
            ans += v * 1.0 / w * p;
            capacity -= v;
        }
        return capacity > 0 ? -1 : ans;
    }
};
```
## 地皮
```cpp
int maxLandPlots(const std::vector<int>& gain, int target) {  
  int n = gain.size();  
  std::vector<std::vector<int>> dp(n, std::vector<int>(n, 0));  
  int max_plots = 0;  
  
  // 初始化 dp 数组  
  for (int i = 0; i < n; ++i) {  
    dp[i][i] = gain[i];  
    if (dp[i][i] == target) {  
      max_plots = 1;  
    }  }  
  // 填充 dp 数组  
  for (int len = 2; len <= n; ++len) {  
    for (int i = 0; i <= n - len; ++i) {  
      int j = i + len - 1;  
      dp[i][j] = dp[i][j - 1] + gain[j];  
      if (dp[i][j] == target) {  
        max_plots = std::max(max_plots, len);  
      }    }  }  
  return max_plots;  
}
```

# 仓库
```cpp
class Solution {
 public:
  std::string vectorToString(const std::vector%3Cint%3E& vec) {
    std::string result;
    for (int num : vec) {
      result += std::to_string(num) + ",";
    }
    return result;
  }

  int minOperationsToSortCargo(std::vector<int>& cargo) {
    int n = cargo.size();
    std::vector<int> target(n);
    for (int i = 0; i < n - 1; ++i) {
      target[i] = i + 1;
    }
    target[n - 1] = 0;

    std::queue<std::pair<std::vector<int>, int>> q;
    std::unordered_set<std::string> visited;

    q.push({cargo, 0});
    visited.insert(vectorToString(cargo));

    while (!q.empty()) {
      auto [current, steps] = q.front();
      q.pop();

      if (current == target || std::is_sorted(current.begin(), current.end() - 1)) {
        return steps;
      }

      int empty_pos = std::find(current.begin(), current.end(), 0) - current.begin();

      for (int i = 0; i < n; ++i) {
        if (i != empty_pos) {
          std::vector<int> next = current;
          std::swap(next[empty_pos], next[i]);
          std::string next_str = vectorToString(next);
          if (visited.find(next_str) == visited.end()) {
            q.push({next, steps + 1});
            visited.insert(next_str);
          }
        }
      }
    }

    return -1;  // 不应该到达这里
  }
};
```