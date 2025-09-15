package com.example.kmpdemo.androidApp

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import Greeting
import UserRepository

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val greeting = Greeting()
        val userRepository = UserRepository()
        
        val textView = TextView(this).apply {
            text = buildString {
                appendLine(greeting.greet())
                appendLine("\n用户数量: ${userRepository.getUserCount()}")
                appendLine("\n用户列表:")
                userRepository.getAllUsers().forEach { user ->
                    appendLine("- ${user.name} (${user.email})")
                }
            }
            textSize = 16f
            setPadding(32, 32, 32, 32)
        }
        
        setContentView(textView)
    }
}