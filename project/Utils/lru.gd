class_name LRUCache

var cap
var head
var tail
var m

func _init(capacity: int):
	self.cap = capacity
	self.head = DLLNode.new(-1)
	self.tail = DLLNode.new(-1)
	self.head.next = self.tail
	self.tail.prev = self.head
	self.m = {}

func get_node(key: int):
	if key in m:
		var res_node = m[key]
		var ans = res_node.val
		m.erase(key)
		_delete_node(res_node)
		_add_node(res_node)
		m[key] = head.next
		return ans
	return -1

func put_node(key: int):
	if key in m:
		var curr = m[key]
		m.erase(key)
		_delete_node(curr)

	if len(m) == cap:
		m.erase(tail.prev.key)
		_delete_node(tail.prev)

	_add_node(DLLNode.new(key))
	m[key] = head.next

func _add_node(newnode):
	var temp = head.next
	newnode.next = temp
	newnode.prev = head
	head.next = newnode
	temp.prev = newnode

func _delete_node(delnode):
	var prevv = delnode.prev
	var nextt = delnode.next
	prevv.next = nextt
	nextt.prev = prevv
