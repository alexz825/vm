struct Reader {
    let data: Data

    func readByte() -> Byte {
        return self.data
    }
}