function getTypeName(type) {
	switch (type) {
	case 'single':
		return '单项选择';
	case 'multiple':
		return '多项选择';
	case 'text':
		return '文本';
	}
}