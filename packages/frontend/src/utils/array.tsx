

// 交换数组中的两个元素
export const swapItem = (arr: any[], first: number, second: number): void => {
    if (!arr.length || first === second || first < 0 || second < 0 || first >= arr.length || second >= arr.length) {
        // 越界不处理
        return
    }

    const temp = arr[first]
    arr[first] = arr[second]
    arr[second] = temp
}