# G1 项目工程结构 Spec (2D 载具射击)

**版本:** 1.0
**适用引擎:** Godot 4.5
**设计核心:** **组件化、数据驱动、自动卷轴驱动。**
**维护目标:** 确保武器、僚机和敌人能够通过简单的 Resource 配置快速扩展，同时通过信号总线解耦游戏逻辑与 UI。

---

## 1. 根目录结构概览 (`res://`)

```text
res://
├── _Autoloads/            # [全局] 单例与管理器
│   ├── GameEvents.gd      # 信号总线 (解耦玩家、敌人、UI)
│   ├── GameManager.gd     # 核心状态 (分数、等级、暂停)
│   └── Config.gd          # 全局常量 (速度限制、卷轴速度)
│
├── Assets/                # [资源] 原始素材
│   ├── Art/               # 纹理、精灵图
│   ├── Audio/             # BGM、音效
│   └── Fonts/             # 字体文件
│
├── Data/                  # [配置] 数值定义 (策划工作区)
│   ├── Resources/         # .tres 实例 (Weapon_Spread.tres, Wingman_Shield.tres)
│   └── Definitions/       # 数据结构定义脚本 (继承自 Resource)
│
├── Gameplay/              # [核心] 游戏逻辑模块
│   ├── Common/            # 通用组件 (HealthComponent.gd, Hitbox.gd)
│   ├── Player/            # 玩家载具逻辑与预制体
│   ├── Wingmen/           # 僚机系统 (不同模式的 AI 与行为)
│   ├── Enemies/           # 敌人基类与具体实现
│   ├── Projectiles/       # 各种子弹、激光逻辑
│   └── Levels/            # 关卡逻辑 (卷轴控制、缓冲段管理)
│
├── UI/                    # [界面] 用户界面
│   ├── HUD/               # 战斗中血条、护盾条、XP条
│   ├── Menus/             # 升级选择菜单、死亡结算
│   └── Common/            # 通用控件
│
├── Scenes/                # [入口] 关卡与测试场
│   ├── Main.tscn          # 游戏主入口
│   ├── Levels/            # 具体关卡场景 (Level_01.tscn)
│   └── _Sandboxes/        # 开发者个人测试场景
│
└── docs/                  # [文档] 项目文档 (Godot 忽略)
```

---

## 2. 核心开发规范

### 2.1 模块化与“高内聚” (Co-location)
*   **原则**：如果一个功能是独有的（例如：某种特殊 Boss），其专属的脚本、子场景应放在同一目录下（如 `Gameplay/Enemies/Boss_Tiger/`）。
*   **例外**：通用的子弹放在 `Gameplay/Projectiles/` 下，以便被不同实体复用。

### 2.2 数据驱动 (Resource First)
*   **原则**：严禁在代码中写死武器伤害、护盾恢复速度、敌人血量。
*   **执行**：
    1.  定义 `WeaponData.gd` (extends Resource)。
    2.  创建 `tres` 文件并配置数值。
    3.  玩家/僚机通过 `export var weapon_info: WeaponData` 引用。

### 2.3 自动卷轴与坐标系 (Scrolling Logic)
*   **原则**：关卡世界是移动的，或者相机是移动的。
*   **当前实现**：由 `LevelManager` 控制相机和玩家的同步位移。
*   **要求**：所有物体在生成时必须考虑是否跟随卷轴，通常作为 `LevelContent` 的子节点生成。

---

## 3. 技术实施细则

### 3.1 载具状态系统 (Stats System)
*   使用两个独立属性：`Health` (生命) 和 `Shield` (护盾)。
*   护盾具有自动恢复逻辑 (10s 恢复 20%)。
*   僚机没有 UI 血条，通过视觉外观（如烟雾特效、变色）展示受损程度。

### 3.2 僚机系统 (Wingman System)
*   最多支持 5 个僚机。
*   僚机模式切换：集中 (Concentrated) vs 分散 (Spread)。
*   防御型僚机使用 `Area2D` 并在 `_on_area_entered` 中检测 `enemy_bullets` 组。

### 3.3 升级与缓冲段 (Upgrades & Buffers)
*   缓冲段通过禁用 `Spawner` 并生成 `SwapStation` 来实现。
*   升级时，通过 `get_tree().paused = true` 弹出 UI，选择后再恢复。

---

## 4. 命名规范

*   **文件夹/场景/脚本**：`PascalCase` (例如 `EnemyScout.tscn`)。
*   **资源文件 (.tres)**：`snake_case` (例如 `player_balanced_gun.tres`)。
*   **信号**：`snake_case` (例如 `signal shield_depleted`)。
*   **方法/变量**：`snake_case` (例如 `func take_damage()`)。

---

## 5. 与 G5 项目工程 Spec 的深度对比与继承

G1 项目在工程结构上高度参考了 G5 项目的成功经验，但也根据“2D 射击”与“大地图自走棋”的品类差异进行了优化。

### 5.1 核心继承点
1.  **信号总线 (GameEvents)**：两个项目都采用单例信号总线来处理跨模块通信（如 UI 更新、音效播放），避免了节点路径的硬编码。
2.  **资源驱动 (Resource-Based)**：G1 沿用了 G5 将属性（攻击力、速度）从逻辑脚本中抽离到 `.tres` 文件的做法。
3.  **所见即所得 (Co-location)**：G1 同样鼓励将特定敌人的场景与脚本放在同一目录下，方便功能的增删。

### 5.2 差异化演进

| 维度 | G5 项目 (参考标杆) | G1 项目 (当前实施) | 演进理由 |
| :--- | :--- | :--- | :--- |
| **目录结构** | `Gameplay/Map/` 占核心地位 | `Gameplay/Levels/` 占核心地位 | G1 的核心是动态卷轴和关卡进度，而非静态大地图。 |
| **实体管理** | `Gameplay/Units/` (阵营驱动) | `Gameplay/Wingmen/` (主角扩展) | G1 是英雄主义射击，重点在于僚机的跟随与形态切换。 |
| **性能重点** | 路径规划 (A*) 与大规模单位 AI | 碰撞检测、对象池 (子弹) | 射击游戏对帧率稳定性要求极高，尤其是大量弹幕。 |
| **数据交互** | 倾向于 JSON/CSV 表格 | 倾向于 Resource (.tres) | 射击项目需要更快的数值迭代周期，Resource 更直观。 |
| **输入处理** | 鼠标交互、菜单驱动 | 强反馈的手柄/键盘、多按键动作映射 | 射击游戏需要处理 8 方向移动和即时模式切换。 |

### 5.3 结论
G1 是 G5 工程框架在 **Action/Shooter** 细分领域的**轻量化、高频化**变体。它保留了 G5 的解耦架构，但将重心从“宏观系统设计”转移到了“微观战斗手感”和“线性关卡推进”。
