#pragma once

#include <list>
#include <unordered_map>
#include <vector>
#include <optional>
#include <stdexcept>

// LRU（最近最少使用）缓存：std::list + std::unordered_map，get/put 均为 O(1)
template <typename K, typename V>
class LruCache {
public:
    explicit LruCache(std::size_t capacity) : capacity_(capacity) {
        if (capacity_ == 0) {
            throw std::invalid_argument("capacity must be > 0");
        }
    }

    std::optional<V> get(const K& key) {
        auto it = map_.find(key);
        if (it == map_.end()) return std::nullopt;
        // 将该节点移动到链表头（最近使用）
        items_.splice(items_.begin(), items_, it->second);
        return it->second->second;
    }

    void put(const K& key, const V& value) {
        auto it = map_.find(key);
        if (it != map_.end()) {
            it->second->second = value;
            items_.splice(items_.begin(), items_, it->second);
        } else {
            items_.emplace_front(key, value);
            map_[key] = items_.begin();
            if (map_.size() > capacity_) {
                auto last = items_.end();
                --last; // 尾部为最久未使用
                map_.erase(last->first);
                items_.pop_back();
            }
        }
    }

    std::optional<V> remove(const K& key) {
        auto it = map_.find(key);
        if (it == map_.end()) return std::nullopt;
        V value = it->second->second;
        items_.erase(it->second);
        map_.erase(it);
        return value;
    }

    std::size_t size() const { return map_.size(); }

    void clear() {
        map_.clear();
        items_.clear();
    }

    // 返回从最近到最久的键序（用于观测与调试）
    std::vector<K> keys() const {
        std::vector<K> result;
        result.reserve(map_.size());
        for (const auto& kv : items_) {
            result.push_back(kv.first);
        }
        return result;
    }

private:
    std::size_t capacity_;
    std::list<std::pair<K, V>> items_; // 前端为最近使用（MRU）
    std::unordered_map<K, typename std::list<std::pair<K, V>>::iterator> map_;
};