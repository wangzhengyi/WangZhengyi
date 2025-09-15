class Greeting {
    private val platform = getPlatform()

    fun greet(): String {
        return "Hello, ${platform.name}!"
    }
}

data class User(
    val id: Int,
    val name: String,
    val email: String
)

class UserRepository {
    private val users = mutableListOf<User>()
    
    init {
        // 添加一些示例数据
        users.addAll(listOf(
            User(1, "张三", "zhangsan@example.com"),
            User(2, "李四", "lisi@example.com"),
            User(3, "王五", "wangwu@example.com")
        ))
    }
    
    fun getAllUsers(): List<User> = users.toList()
    
    fun addUser(user: User) {
        users.add(user)
    }
    
    fun getUserById(id: Int): User? = users.find { it.id == id }
    
    fun deleteUser(id: Int): Boolean {
        val userToRemove = users.find { it.id == id }
        return if (userToRemove != null) {
            users.remove(userToRemove)
        } else {
            false
        }
    }
    
    fun getUserCount(): Int = users.size
}